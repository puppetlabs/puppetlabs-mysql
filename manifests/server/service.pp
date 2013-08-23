class mysql::server::service(
  $enabled = $mysql::server::enabled,
  $manage_service = $mysql::server::manage_service,
  $service_name = $mysql::server::service_name,
  $manage_config_file = $mysql::manage_config_file,
  $config_file = $mysql::config_file,
  $service_provider = $mysql::service_provider
) {
  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  if $manage_service {
    service { 'mysqld':
      ensure   => $service_ensure,
      name     => $service_name,
      enable   => $enabled,
      require  => Package['mysql-server'],
      subscribe => $manage_config_file ? {
        true => File[$config_file],
        false => undef,
      },
      provider => $service_provider,
    }
  }
}
