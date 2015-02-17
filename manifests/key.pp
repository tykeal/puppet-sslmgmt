# == Define: sslmgmt::key
#
# Manage SSL keys for certs
#
# === Variables
#
# [*pkistore*]
#   The PKI store that should be used
#   See the params.pp for the different options
#   A store of 'custom' is also allowed in which case the customstore
#   variable must be set
#
# [*ensure*]
#   Ensure that the key does or does not exist
#   Default: true
#   Options:
#     true (or present)
#     false ( or absent)
#
# [*chain*]
#   
define sslmgmt::key (
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

}
