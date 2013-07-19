# Class: mysql::bindings::python
#
# This class installs the python libs for mysql.
#
# Parameters:
#   [*package_ensure*] - Ensure state for package. Can be specified as version.
#   [*package_name*]   - Name of package
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::bindings::python(
  $package_ensure = $mysql::bindings::python_package_ensure,
  $package_name   = $mysql::bindings::python_package_name
) inherits mysql {

  package { 'python-mysqldb':
    ensure => $package_ensure,
    name   => $package_name,
  }

}
