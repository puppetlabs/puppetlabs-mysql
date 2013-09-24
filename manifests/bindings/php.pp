# Private class: See README.md
class mysql::bindings::php(
  $package_ensure = $mysql::params::php_package_ensure,
  $package_name   = $mysql::params::php_package_name,
) {

  package { 'php-mysql':
    ensure   => $package_ensure,
    name     => $package_name,
    provider => $mysql::bindings::php_package_provider,
  }

}
