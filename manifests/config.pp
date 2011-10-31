class mysql::config(
  $root_password = 'UNSET',
  $old_root_password = '',
  $bind_address = '127.0.0.1',
  $port = 3306,
  # rather or not to store the rootpw in /etc/my.cnf
  $etc_root_password = false
) {

  # manage root password if it is set
  if !($root_password == 'UNSET') {
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
    file{'/root/.my.cnf':
      content => template('mysql/my.cnf.pass.erb'),
    }
    if $etc_root_password {
       file{'/etc/my.cnf':
          content => template('mysql/my.cnf.pass.erb'),
          require => Exec['set_mysql_rootpw'],
       }
    }
  }
  File {
    owner => 'root',
    group => 'root',
    mode  => '0400',
    notify  => Exec['mysqld-restart'],
    require => Package['mysql-server']
  }
  file { '/etc/mysql':
    ensure => directory,
    mode => '755',
  }

  file { '/etc/mysql/my.cnf':
    content => template('mysql/my.cnf.erb'),
  }
}
