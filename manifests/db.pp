#
# this creates a single mysql db, with one user and grants priveleges
#   db
#   db_user
#   db_pw
#
define mysql::db (
  $user,
  $password,
  $charset = 'utf8',
  $host = 'localhost',
  $grant='all',
  $sql=''
) {
  #
  notice($user)
  database { $name:
    ensure => present,
    charset => $charset,
    provider => 'mysql',
    require => Class['mysql::server']
  }
  database_user{"${user}@${host}":
    ensure => present,
    password_hash => mysql_password($password),
    provider => 'mysql',
    require => Database[$name],
  }
  database_grant{"${user}@${host}/${name}":
  # privileges => [ 'alter_priv', 'insert_priv', 'select_priv', 'update_priv' ],
    privileges => $grant,
    provider => 'mysql',
    require => Database_user["${user}@${host}"],
  }
  if($sql) {
    exec{"${name}-import-import":
      command => "/usr/bin/mysql -u ${user} -p${password} -h ${host} ${name} < ${sql}",
      logoutput => true,
      require => Database_grant["${user}@${host}/${name}"],
    }
  }
} 
