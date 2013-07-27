class mysql::python(
  $package_ensure = $mysql::params::python_package_ensure,
  $package_name   = $mysql::params::python_package_name,
) inherits mysql::params {

  notify { "mysql::python has been renamed to mysql::bindings::python and this
  backwards compatibility shim will be removed on 01/01/2014.": }

  class { 'mysql::bindings::python':
    package_ensure => $package_ensure,
    package_name   => $package_name,
  }

}
