$mysql_root_pw='password'
class { 'mysql::server':
  root_password => 'password',
}
#database_user{['test1@localhost', 'test2@localhost', 'test3@localhost']:
database_user{'redmine@localhost':
#  ensure => absent,
  ensure => present,
  password_hash => mysql_password('redmine'),
  require => Class['mysql::server'],
}

database_user{'dan@localhost':
  ensure => present,
  password_hash => mysql_password('blah')
}
