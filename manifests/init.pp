# Class: mysql
#
# this module installs mysql client software.
#
# Parameters:
#   [*client_package_name*]  - The name of the mysql client package.
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql(
  $client_package_name = $mysql::params::client_package_name
) inherits mysql::params {
  package {"mysql-client":
    name    => $client_package_name,
    ensure  => installed,
  }
}
