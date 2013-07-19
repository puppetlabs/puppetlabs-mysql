class mysql::client::install(
  $package_name   = $mysql::client_package_name,
  $package_ensure = $mysql::client_package_ensure
) {

  package { 'mysql_client':
    ensure => $package_ensure,
    name   => $package_name,
  }

}
