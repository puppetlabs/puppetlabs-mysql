#
class mysql::server::service {
  $options = $mysql::server::options

  if $mysql::server::real_service_manage {
    if $mysql::server::real_service_enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  if $mysql::server::override_options['mysqld'] and $mysql::server::override_options['mysqld']['user'] {
    $mysqluser = $mysql::server::override_options['mysqld']['user']
  } else {
    $mysqluser = $options['mysqld']['user']
  }

  file { $options['mysqld']['log-error']:
    ensure => present,
    owner  => $mysqluser,
    group  => $::mysql::server::root_group,
  }

  service { 'mysqld':
    ensure   => $service_ensure,
    name     => $mysql::server::service_name,
    enable   => $mysql::server::real_service_enabled,
    provider => $mysql::server::service_provider,
    require  => [ File['mysql-config-file'], Package['mysql-server'] ]
  }

}
