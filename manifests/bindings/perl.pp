# Class: mysql::bindings::perl
#
# installs the perl bindings for mysql
#
# Parameters:
#   [*package_ensure*]   - Ensure state for package. Can be specified as version.
#   [*package_name*]     - name of package
#   [*package_provider*] - The provider to use to install the package
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::bindings::perl (
  $package_ensure   = $mysql::bindings::perl_package_ensure,
  $package_name     = $mysql::bindings::perl_package_name,
  $package_provider = $mysql::bindings::perl_package_provider
) inherits mysql {

  package{ 'perl_mysql':
    ensure   => $package_ensure,
    name     => $package_name,
    provider => $package_provider,
  }

}
