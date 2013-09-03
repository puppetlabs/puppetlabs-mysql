#This is a helper class to add a monitoring user to the database
#
class mysql::server::monitor (
  $mysql_monitor_username,
  $mysql_monitor_password,
  $mysql_monitor_hostname
) {

  Class['mysql::server'] -> Class['mysql::server::monitor']

  mysql_user{ "${mysql_monitor_username}@${mysql_monitor_hostname}":
    ensure        => present,
    password_hash => mysql_password($mysql_monitor_password),
  }

  mysql_grant { "${mysql_monitor_username}@${mysql_monitor_hostname}":
    ensure     => present,
    user       => "${mysql_monitor_username}@${mysql_monitor_hostname}",
    table      => '*.*',
    privileges => [ 'PROCESS_PRIV', 'SUPER_PRIV' ],
    require    => Mysql_user["${mysql_monitor_username}@${mysql_monitor_hostname}"],
  }

}
