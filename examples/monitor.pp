# @summary
#   Add a monitoring user to the database

$mysql_monitor_password = 'password'
$mysql_monitor_username = 'monitoring'
$mysql_monitor_hostname = $facts['networking']['hostname']

mysql_user { "${mysql_monitor_username}@${mysql_monitor_hostname}":
  ensure        => present,
  password_hash => mysql::password($mysql_monitor_password),
  require       => Class['mysql::server::service'],
}

mysql_grant { "${mysql_monitor_username}@${mysql_monitor_hostname}/*.*":
  ensure     => present,
  user       => "${mysql_monitor_username}@${mysql_monitor_hostname}",
  table      => '*.*',
  privileges => ['PROCESS', 'SUPER'],
  require    => Mysql_user["${mysql_monitor_username}@${mysql_monitor_hostname}"],
}
