#
# this creates a single mysql db, with one user and grants priveleges
#   db
#   db_user
#   db_pw
#
define mysql::db ( $db_user, $db_pw, $db_charset = 'utf8', $host = 'localhost', $grant='all', $sql='') {
  #
  database { $name:
    ensure => present,
    charset => $db_charset,
    provider => 'mysql',
    require => Class['mysql::server']
  }
  database_user{"${db_user}@${host}":
    ensure => present,
    password_hash => mysql_password($db_pw),
    provider => 'mysql',
    require => Database[$name],
  }
  database_grant{"${db_user}@${host}/${name}":
  # privileges => [ 'alter_priv', 'insert_priv', 'select_priv', 'update_priv' ],
    privileges => $grant,
    provider => 'mysql',
    require => Database_user["${db_user}@${host}"],
  }
  if($sql) {
    exec{"${name}-import-import":
      command => "/usr/bin/mysql -u ${db_user} -p${db_pw} -h ${host} ${name} < ${sql}",
      logoutput => true,
      require => Database_grant["${db_user}@${host}/${name}"],
    }
  }
} 
