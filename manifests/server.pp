# Class: mysql::server
#
# manages the installation of the mysql server.
#   manages the package, service, my.cnf
#
# Parameters:
#   [*config_hash*]       - hash of config parameters that need to be set.
#   [*service_name*]      - name of service
#   [*package_name*]      - name of package
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::server(
  $service_name = $mysql::params::service_name,
  $config_hash  = {},
  $package_name = 'mysql-server'
) inherits mysql::params {

  # automatically create a class to deal with
  # configuration
  $hash = {
    "mysql::config" => $config_hash
  }
  create_resources("class", $hash)

  package{'mysql-server':
    name   => $package_name,
    ensure => present,
    notify => Service['mysqld'],
  }
  service { 'mysqld':
    name => $service_name,
    ensure => running,
    enable => true,
  }
  # this kind of sucks, that I have to specify a difference resource for restart.
  # the reason is that I need the service to be started before mods to the config
  # file which can cause a refresh
  exec{ 'mysqld-restart':
    command     => "service ${service_name} restart",
    refreshonly => true,
    path        => '/sbin/:/usr/sbin/',
  }
  File{
    owner   => 'mysql',
    group   => 'mysql',
    require => Package['mysql-server'],
  }
}
