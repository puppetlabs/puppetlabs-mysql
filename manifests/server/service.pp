#
class mysql::server::service (
  $real_service_manage  = $mysql::server::real_service_manage,
  $manage_config_file   = $mysql::server::manage_config_file,
  $real_service_enabled = $mysql::server::real_service_enabled,
  $log_error            = $mysql::params::log_error,
  $service_name         = $mysql::server::service_name,
  $service_provider     = $mysql::server::service_provider
) inherits mysql::params {

  if $real_service_manage {
    if $real_service_enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  file { $log_error:
    ensure => present,
    owner  => 'mysql',
    group  => 'mysql',
  }

  if $manage_config_file {
    $service_require =  [ File['mysql-config-file'], Package['mysql-server'] ]
  } else {
    $service_require =  [ Package['mysql-server'] ]
  }

  service { 'mysqld':
    ensure   => $service_ensure,
    name     => $service_name,
    enable   => $real_service_enabled,
    provider => $service_provider,
    require  => $service_require 
  }

}
