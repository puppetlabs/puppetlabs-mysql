class mysql::java(
  $package_ensure = $mysql::params::java_package_ensure,
  $package_name = $mysql::params::java_package_name,
) inherits mysql::params {

  notify { "mysql::java has been renamed to mysql::bindings::java and this
  backwards compatibility shim will be removed on 01/01/2014.": }

  class { 'mysql::bindings::java':
    package_ensure => $package_ensure,
    package_name   => $package_name,
  }

}
