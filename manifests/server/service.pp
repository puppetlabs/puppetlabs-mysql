#
class mysql::server::service {

  if $mysql::server::real_service_manage {
    if $mysql::server::real_service_enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  file { $mysql::params::log_error:
    ensure => present,
    owner  => 'mysql',
    group  => 'mysql',
  }

  service { 'mysqld':
    ensure   => $service_ensure,
    name     => $mysql::server::service_name,
    enable   => $mysql::server::real_service_enabled,
    provider => $mysql::server::service_provider,
    # if you manage the config file outside of the module or want mysql provided by another package, you may still use this service
    # provided you set the parameters config_file resp. package_name on the mysql::server class
    require  => [ File[$mysql::server::config_file], Package[$mysql::server::package_name]]
  }

}
