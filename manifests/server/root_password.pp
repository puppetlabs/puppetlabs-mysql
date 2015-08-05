#
class mysql::server::root_password {

  $options = $mysql::server::options

  # manage root password if it is set
  if $mysql::server::create_root_user == true and $mysql::server::root_password != 'UNSET' {
    mysql_user { 'root@localhost':
      ensure        => present,
      password_hash => mysql_password($mysql::server::root_password),
    }
  }

  if $mysql::server::create_root_my_cnf == true and $mysql::server::root_password != 'UNSET' {
    file { "${::root_home}/.my.cnf":
      content => template('mysql/my.cnf.pass.erb'),
      owner   => 'root',
      mode    => '0600',
    }

    # show_diff was added with puppet 3.0
    if versioncmp($::puppetversion, '3.0') <= 0 {
      File["${::root_home}/.my.cnf"] { show_diff => false }
    }
    if $mysql::server::create_root_user == true {
      Mysql_user['root@localhost'] -> File["${::root_home}/.my.cnf"]
    }
  }

}
