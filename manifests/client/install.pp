class mysql::client::install {

  if ! defined ( Package[$mysql::client::package_name] ) {
    package { 'mysql_client':
      ensure => $mysql::client::package_ensure,
      name   => $mysql::client::package_name,
    }
  }
}
