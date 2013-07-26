class mysql::ruby(
  $package_ensure   = $mysql::params::ruby_package_ensure,
  $package_name     = $mysql::params::ruby_package_name,
  $package_provider = $mysql::params::ruby_package_provider,
) inherits mysql::params {

  notify { "mysql::ruby has been renamed to mysql::bindings::ruby and this
  backwards compatibility shim will be removed on 01/01/2014.": }

  class { 'mysql::bindings::ruby':
    package_ensure   => $package_ensure,
    package_name     => $package_name,
    package_provider => $package_provider,
  }

}
