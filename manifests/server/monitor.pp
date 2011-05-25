# install mysql user to allow remote monitoring
class mysql::server::monitor {
  if(!$mysql_monitor_username) {
    fail('$mysql_monitor_username not defined')
  }
  if(!$mysql_monitor_password) {
    fail('$mysql_monitor_password not defined')
  }
  if(!$mysql_monitor_hostname) {
    fail('$mysql_monitor_hostname not defined')
  }
  mysql_user{ 
    "${mysql_monitor_username}@${mysql_monitor_hostname}":
      password_hash => mysql_password($mysql_monitor_password),
      ensure        => present,
      require       => Service['mysqld'],
  }
  mysql_grant { "${mysql_monitor_username}@${mysql_monitor_hostname}":
    privileges    => [ 'process_priv', 'super_priv' ],
    require       => [ Mysql_user["${mysql_monitor_username}@${mysql_monitor_hostname}"], Service['mysqld']],
  }
}
