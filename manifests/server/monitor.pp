#This is a helper class to add a monitoring user to the database
class mysql::server::monitor (
  $mysql_monitor_username,
  $mysql_monitor_password,
  $mysql_monitor_hostname,
  $hashed_password = false
) {

  Anchor['mysql::server::end'] -> Class['mysql::server::monitor']

  if !$hashed_password {
    $mysql_monitor_password_hash = mysql_password($mysql_monitor_password)
  }


  mysql_user { "${mysql_monitor_username}@${mysql_monitor_hostname}":
    ensure        => present,
    password_hash => ,
    require       => Class['mysql::server::service'],
  }

  mysql_grant { "${mysql_monitor_username}@${mysql_monitor_hostname}/*.*":
    ensure     => present,
    user       => "${mysql_monitor_username}@${mysql_monitor_hostname}",
    table      => '*.*',
    privileges => [ 'PROCESS', 'SUPER' ],
    require    => Mysql_user["${mysql_monitor_username}@${mysql_monitor_hostname}"],
  }

}
