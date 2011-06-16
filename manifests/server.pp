# Class: mysql::server
#
# manages the installation of the mysql server.
#   manages the package, service, my.cnf
#
# Parameters:
#   [*root_password*]     - root password for database
#   [*old_root_password*] - previous root password if being changed
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
  $root_password = undef,
  $old_root_password = undef,
  $package_name = 'mysql-server'
) inherits mysql::params {

  case $operatingsystem {
    'centos', 'redhat', 'fedora': {
      class { 'mysql::server::redhat':
        root_password     => $root_password,
        old_root_password => $old_root_password,
      }
    }
    'ubuntu', 'debian': {
      # there is not any debian specific config yet
    }
  }

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
    path        => '/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:',
  }
  File{
    owner   => 'mysql',
    group   => 'mysql',
    require => Package['mysql-server'],
  }
}