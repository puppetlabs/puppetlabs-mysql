class mysql::python(
  $ensure = installed,
  $package_name = $mysql::params::python_package_name
) inherits mysql::params {

  package { 'python-mysqldb':
    name => $package_name,
    ensure => $ensure,
  }
}
