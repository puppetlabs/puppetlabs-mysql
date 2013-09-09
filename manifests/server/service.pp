#
class mysql::server::service {

  if $mysql::server::enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  if $mysql::server::manage_service {
    service { 'mysqld':
      ensure   => $service_ensure,
      name     => $mysql::server::service_name,
      enable   => $mysql::server::enabled,
      provider => $mysql::server::service_provider,
    }
  }

}
