class mysql::php(
  $package_ensure = $mysql::params::php_package_ensure,
  $package_name   = $mysql::params::php_package_name,
) inherits mysql::params {

  notify { "mysql::php has been renamed to mysql::bindings::php and this
  backwards compatibility shim will be removed on 01/01/2014.": }

  class { 'mysql::bindings::php':
    package_ensure => $package_ensure,
    package_name   => $package_name,
  }

}
