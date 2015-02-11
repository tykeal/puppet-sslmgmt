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

  # customstore is only used if pkistore is set to custom
  # It is then required to be a hash
  if ($pkistore == 'custom') {
    validate_hash($customstore)
  }

}
