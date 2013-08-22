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
      require  => Package['mysql-server'],
      subscribe => $mysql::manage_config_file ? {
        true => File[$mysql::config_file],
        false => undef,
      },
      provider => $mysql::server::service_provider,
    }
  }
}
