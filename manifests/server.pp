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
  $root_password,
  $old_root_password = '',
  $service_name = $mysql::params::service_name,
  $package_name = 'mysql-server'
) inherits mysql::params {
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
    command => "/usr/sbin/service ${service_name} restart",
    refreshonly => true,
  }
  File{
    owner   => 'mysql',
    group   => 'mysql',
    require => Package['mysql-server'],
  }
  # use the previous password for the case where its not configured in /root/.my.cnf
  case $old_root_password {
    '': {$old_pw=''}
    default: {$old_pw="-p${old_root_password}"}  
  }
  exec{ 'set_mysql_rootpw':
    command   => "mysqladmin -u root ${old_pw} password ${root_password}",
    #logoutput => on_failure,
    logoutput => true,
    unless   => "mysqladmin -u root -p${root_password} status > /dev/null",
    path      => '/usr/local/sbin:/usr/bin',
    require   => [Package['mysql-server'], Service['mysqld']],
    before    => File['/root/.my.cnf'],
    notify    => Exec['mysqld-restart'],
  } 

  file{['/root/.my.cnf', '/etc/mycnf']:
    owner => 'root',
    group => 'root',
    mode  => '0400',
    content => template('mysql/my.cnf.erb'),
    notify => Exec['mysqld-restart'],
  }
}
