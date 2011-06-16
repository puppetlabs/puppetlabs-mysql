class mysql::server::redhat(
  $root_password,
  $old_root_password = ''
) {
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
  file{['/root/.my.cnf', '/etc/my.cnf']:
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => template('mysql/my.cnf.erb'),
    notify  => Exec['mysqld-restart'],
    require => Package['mysql-server'],
  }
}
