# Class: mysql::server
#
# manages the installation of the mysql server.  manages the package, service,
# my.cnf
#
# Parameters:
#  [*config_hash*]      - hash of config parameters that need to be set.
#  [*enabled*]          - Defaults to true, boolean to set service ensure.
#  [*manage_service*]   - Boolean dictating if mysql::server should manage the service
#  [*package_ensure*]   - Ensure state for package. Can be specified as version.
#  [*server_package_name*]     - The name of package
#  [*client_package_name*]     - The name of package
#  [*service_name*]     - The name of service
#  [*service_provider*] - What service provider to use.

#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::server (
  $config_hash      = {},
  $enabled          = true,
  $manage_service   = true,
  $package_ensure   = $mysql::params::package_ensure,
  $server_package_name
                    = $mysql::params::server_package_name,
  $client_package_name
                    = $mysql::params::client_package_name,
  $service_name     = $mysql::params::service_name,
  $service_provider = $mysql::params::service_provider,
  $pidfile          = $mysql::params::pidfile
) inherits mysql::params {

  class {'mysql': 
    client_package_name => $client_package_name  
  }
   
  notice("client package set to $client_package_name")
  
  Class['mysql::server'] -> Class['mysql::config']

  $config_class = { 'mysql::config' => $config_hash }
  $piddir       =   dirname($pidfile)

  create_resources( 'class', $config_class )

  package { 'mysql-server':
    ensure => $package_ensure,
    name   => $server_package_name,
  }

  file { $piddir:
    ensure => directory,
    owner  => 'mysql',
    group  => 'mysql',
    mode   => '0755',
    require=> Package['mysql-server'],
  }

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
      provider => $service_provider,
    }
  }
}
