# Class: mysql::bindings::java
#
# This class installs the mysql-java-connector.
#
# Parameters:
#   [*package_name*]       - The name of the mysql java package.
#   [*package_ensure*]     - Ensure state for package. Can be specified as version.
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::bindings::java (
  $package_ensure = $mysql::bindings::java_package_ensure,
  $package_name   = $mysql::bindings::java_package_name
) inherits mysql {

  package { 'mysql-connector-java':
    ensure => $package_ensure,
    name   => $package_name,
  }

}
