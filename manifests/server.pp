# installs mysql 
class mysql::server(
  $mysql_root_pw,
  $mysql_old_pw = ''
) {
  package{'mysql-server':
    name   => 'mysql-server',
    ensure => installed,
    notify => Service['mysqld'],
  }
  service { 'mysqld':
    name => $operatingsystem?{
      ubuntu  => 'mysql',
      debian  => 'mysql',
      default => 'mysqld',
    },
    ensure => running,
    enable => true,
  }
  # this kind of sucks, that I have to specify a difference resource for restart.
  # the reason is that I need the service to be started before mods to the config
  # file which can cause a refresh
  exec{ 'mysqld-restart':
    command => '/usr/sbin/service mysqld restart',
    refreshonly => true,
  }
  File{
    owner   => 'mysql',
    group   => 'mysql',
    require => Package['mysql-server'],
  }
  # use the previous password for the case where its not configured in /root/.my.cnf
  case $mysql_old_pw {
    '': {$old_pw=''}
    default: {$old_pw="-p${mysql_old_pw}"}  
  }
  exec{ 'set_mysql_rootpw':
    command   => "mysqladmin -u root ${old_pw} password ${mysql_root_pw}",
    #logoutput => on_failure,
    logoutput => true,
    unless   => "mysqladmin -u root -p${mysql_root_pw} status > /dev/null",
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
