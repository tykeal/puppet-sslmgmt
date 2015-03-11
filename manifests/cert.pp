# == Define: sslmgmt::cert
#
# Manage SSL certs and chain them when requested
#
# === Variables
#
# [*pkistore*]
#   The PKI store that should be used
#   See the params.pp file for the different options
#   A store of 'custom' requires that the path be set
#   This variable is required to be set
#
# [*ensure*]
#   Ensure the certificate does or does not exist
#   Default: true
#   Options:
#     true (or present)
#     false (or absent)
#
# [*chain*]
#   The key to lookup out of hiera for chaining purposes
#   If it is the empty string then no chaining will be performed
#   Default: undef
#
# [*customstore*]
#   A hash containing custom certificate store information
#   NOTE: This is required if pkistore is set to 'custom'
#
#   The definition of the hash is as follows:
#
#   {
#     'certpath' => 'fully qualified storage path for the cert',
#     'keypath'  => 'fully qualified storage path for the key',
#     'certmode' => 'the file mode to apply to the cert',
#     'owner'    => 'certificate owner',
#     'group'    => 'certificate group owner',
#   }
#
#   NOTE: if a key is not specified in the hash then the when needed it
#   will be loaded from the ::sslmgmt::params::pkistore 'default'
#   pkistore
#
#   NOTE: there is an extra key of 'certfilename' that may be used to
#   override the certfilename that is used for the destination file. This
#   key is only available when using a custom pkistore
#
#   NOTE: there is an extra key of 'keyfilename' that may be used to
#   override the keyfilename that is used for the destination key. This
#   is only available when using a custom pkistore
#
# [*installkey*]
#   Boolean to determine if the certificate key should also be installed
#   Default: true
#
# [*onefile*]
#   Boolean to determine if the key & certificate should be installed as
#   a single combined file. This setting expects that install key is
#   true
# 
#   NOTE: The public cert file will still be written out per normal but
#   the keyfile will also have the fully realized certfile appended to
#   the end as well.
#
#   Default: false
#
# === Examples
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2015 Andrew Grimberg
#
# === License
#
# @License Apache-2.0 <http://spdx.org/licenses/Apache-2.0>
#
define sslmgmt::cert (
  $pkistore,
  $ensure       = true,
  $chain        = undef,
  $customstore  = undef,
  $installkey   = true,
  $onefile      = false,
) {
  # load the params class so we can get our pkistore types
  include ::sslmgmt::params

  # verify that pkistore is
  # a) a string
  # b) one of the pkistore hash types or custom
  validate_string($pkistore)
  if ($pkistore != 'custom') and
    (!has_key($::sslmgmt::params::pkistore, $pkistore)) {
    fail('pkistore must be either custom or a value from params')
  }

  # verify that ensure is a valid option
  if (! is_bool($ensure)) {
    if (! ($ensure in ['present', 'absent'])) {
      fail("ensure must be one of true, false, 'present', or 'absent'")
    }
  }

  # validate our booleans
  validate_bool($installkey)
  validate_bool($onefile)

  # get our certificate hash
  $certificates = hiera('sslmgmt::certs')
  validate_hash($certificates)
  
  # make sure we actually have a cert
  if (! has_key($certificates, $title)) {
    fail("please ensure that ${title} exists in hiera sslmgmt::certs")
  }

  # make sure that there is a chain store if it's being requested
  if ($chain) {
    validate_string($chain)

    $ca = hiera('sslmgmt::ca')
    validate_hash($ca)

    if (! has_key($ca, $chain)) {
      fail("please ensure that ${chain} exists in hiera sslmgmt::ca")
    }
    else {
      $cacert = $ca[$chain]
    }
  }

  # make sure the define cert actually has needed values
  $certstore = $certificates[$title]
  validate_hash($certstore)

  if (! has_key($certstore, 'cert')) {
    fail("certificate ${title} does not have a 'cert' value")
  }
  else {
    $cert = $certstore['cert']
  }

  # we only care if there is a key if we are supposed to install the key
  if ($installkey) {
    if (! has_key($certstore, 'key')) {
      fail("certificate ${title} does not have a 'key' value")
    }
    else {
      $key = $certstore['key']
    }
  }

  # crack out the default pkistore as we need to use it for a few
  # operations
  $_default_pkistore = $sslmgmt::params::pkistore['default']
  validate_hash($_default_pkistore)

  # customstore is only used if pkistore is set to custom
  # It is then required to be a hash
  if ($pkistore == 'custom') {
    validate_hash($customstore)
  
    # merge the customstore with the default store to get the real
    # pkistore
    $_pkistore = merge($_default_pkistore, $customstore)
  }
  else {
    $_pkistore = merge($_default_pkistore,
        $sslmgmt::params::pkistore[$pkistore])
  }

  if (has_key($_pkistore, 'certfilename')) {
    $_certname = $_pkistore['certfilename']
  }
  else {
    $_certpath = $_pkistore['certpath']

    if ($chain) {
      $_certname = "${_certpath}/${title}-${chain}.pem"
    }
    else {
      $_certname = "${_certpath}/${title}.pem"
    }
  }

  if ($installkey) {
    if (has_key($_pkistore, 'keyfilename')) {
      $_keyname = $_pkistore['keyfilename']
    }
    else {
      $_keypath = $_pkistore['keypath']

      $_keyname = "${_keypath}/${title}.pem"
    }
  }

  # create the cert content
  if ($chain) {
    $_certcontent = "${cert}${cacert}"
  }
  else {
    $_certcontent = $cert
  }

  file { $_certname:
    ensure  => $ensure,
    content => $_certcontent,
    source  => undef,
    owner   => $_pkistore['owner'],
    group   => $_pkistore['group'],
    mode    => $_pkistore['certmode'],
  }

  # write out the key if we need to
  if ($installkey) {
    # determine if we need to write key + cert or just key
    if ($onefile) {
      $_keycontent = "${key}${_certcontent}"
    }
    else {
      $_keycontent = $key
    }

    # keys are always stored mode 0600
    file { $_keyname:
      ensure  => $ensure,
      content => $_keycontent,
      source  => undef,
      owner   => $_pkistore['owner'],
      group   => $_pkistore['group'],
      mode    => '0600',
    }
  }
}
