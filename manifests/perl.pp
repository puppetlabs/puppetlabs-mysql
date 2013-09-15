class mysql::perl(
  $package_ensure   = $mysql::params::perl_package_ensure,
  $package_name     = $mysql::params::perl_package_name,
  $package_provider = $mysql::params::perl_package_provider,
) inherits mysql::params {

  notify { "mysql::perl has been renamed to mysql::bindings::perl and this
  backwards compatibility shim will be removed on 01/01/2014.": }

  class { 'mysql::bindings::perl':
    package_ensure   => $package_ensure,
    package_name     => $package_name,
    package_provider => $package_provider,
  }

}
