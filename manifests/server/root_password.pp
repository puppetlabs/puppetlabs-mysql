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
    # Puppet 2.7 doesnt support show_diff
    if versioncmp($::puppetversion, '3.0') <= 0 {
      file { "${::root_home}/.my.cnf":
        content   => template('mysql/my.cnf.pass.erb'),
        owner     => 'root',
        mode      => '0600',
        show_diff => false,
      }
    } else {
      file { "${::root_home}/.my.cnf":
        content => template('mysql/my.cnf.pass.erb'),
        owner   => 'root',
        mode    => '0600',
      }
    }
    if $mysql::server::create_root_user == true {
      Mysql_user['root@localhost'] -> File["${::root_home}/.my.cnf"]
    }
  }

}
