#
class mysql::server::service {
  $options = $mysql::server::options

  if $mysql::server::real_service_manage {
    if $mysql::server::real_service_enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  } else {
    $service_ensure = undef
  }

  if $mysql::server::override_options and $mysql::server::override_options['mysqld'] and $mysql::server::override_options['mysqld']['user'] {
    $mysqluser = $mysql::server::override_options['mysqld']['user']
  } else {
    $mysqluser = $options['mysqld']['user']
  }

  if $options['mysqld']['log-error'] {
    file { $options['mysqld']['log-error']:
      ensure => present,
      owner  => $mysqluser,
      group  => $::mysql::server::mysql_group,
    }
  }

  service { 'mysqld':
    ensure   => $service_ensure,
    name     => $mysql::server::service_name,
    enable   => $mysql::server::real_service_enabled,
    provider => $mysql::server::service_provider,
  }

  # only establish ordering between service and package if
  # we're managing the package.
  if $mysql::server::package_manage {
    Service['mysqld'] {
      require  => Package['mysql-server'],
    }
  }

  # only establish ordering between config file and service if
  # we're managing the config file.
  if $mysql::server::manage_config_file {
    File['mysql-config-file'] -> Service['mysqld']
  }

}
