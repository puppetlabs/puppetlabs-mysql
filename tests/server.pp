#$mysql_old_pw='password2'
class { 'mysql::server':
  root_password => 'password',
  #old_root_password => 'foo'
}
