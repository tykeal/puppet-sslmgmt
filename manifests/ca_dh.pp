# == Define: sslmgmt::ca_dh
#
# Write out chained CA or DH agreements
#
# This is separate from a chained cert itself as sometimes it's needed
# that the CA chain set be available separately from the cert itself
# (chain => undef). Additionally DH agreements can be treated like CA
# chains for the purpose of being written out
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
#   Default: present
#   Options:
#     present
#     absent
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
#   key is only available when using a custom pkistore. This is the path
#   that will be used for CA and DH key writing
#
#   NOTE: there is an extra key of 'keyfilename' that may be used to
#   override the keyfilename that is used for the destination key. This
#   is only available when using a custom pkistore
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
define sslmgmt::ca_dh (
  $pkistore,
  $ensure       = 'present',
  $customstore  = undef,
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
  validate_string($ensure)
  if (! ($ensure in ['present', 'absent'])) {
    fail("ensure must be one of 'present', or 'absent'")
  } else {
    # ensure of present should actually be file
    if ($ensure == 'present') {
      $_ensure = 'file'
    } else {
      $_ensure = $ensure
    }
  }

  # get our CA hash
  $ca = hiera('sslmgmt::ca')
  validate_hash($ca)

  if (! has_key($ca, $title)) {
    fail("please ensure that ${title} exists in hiera sslmgmt::ca")
  }
  else {
    $cert = $ca[$title]
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
    $_certname = "${_certpath}/${title}.pem"
  }

  file { $_certname:
    ensure  => $_ensure,
    content => $cert,
    owner   => $_pkistore['owner'],
    group   => $_pkistore['group'],
    mode    => $_pkistore['certmode'],
  }
}
