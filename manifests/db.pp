# Define: mysql::db
#
# This module creates database instances, a user,
#  and grants that user privileges to the DB.
#
# Parameters:
#   [*title*]    - database name
#   [*user*]     - user to create
#   [*password*] - user's password
#   [*charset*]  - charset for db
#   [*host*]     - host for assigning privileges to user
#   [*grant*]    - array of privileges to grant to user
#   [*sql*]      - sql to  inject in db (always runs)
#
# Actions:
#
# Requires:
#
# Sample Usage:
# 
#  mysql::db { 'mydb':
#    user     => 'my_user',
#    password => 'password',
#    host     => $::hostname,
#    grant    => ['all']
#  }
#
define mysql::db (
  $user,
  $password,
  $charset = 'utf8',
  $host = 'localhost',
  $grant='all',
  $enforce_sql = false,
  $sql=''
) {

  if $grant == 'all' {
    $safe_grant = [ 'alter_priv','alter_routine_priv','create_priv','create_routine_priv','create_tmp_table_priv','create_view_priv','delete_priv','drop_priv','event_priv','execute_priv','grant_priv','index_priv','insert_priv','lock_tables_priv','references_priv','select_priv','show_view_priv','trigger_priv','update_priv']
  } else {
    $safe_grant = $grant
  }

  database { $name:
    ensure   => present,
    charset  => $charset,
    provider => 'mysql',
    require  => Class['mysql::server'],
    notify   => $sql ? {
      ''      => undef,
      default => Exec["${name}-import-import"],
    }
  }

  database_user{"${user}@${host}":
    ensure        => present,
    password_hash => mysql_password($password),
    provider      => 'mysql',
    require       => Database[$name],
  }

  database_grant{"${user}@${host}/${name}":
  # privileges => [ 'alter_priv', 'insert_priv', 'select_priv', 'update_priv' ],
    privileges => $safe_grant,
    provider   => 'mysql',
    require    => Database_user["${user}@${host}"],
  }

  if($sql) {
    exec{"${name}-import-import":
      command     => "/usr/bin/mysql -u ${user} -p${password} -h ${host} ${name} < ${sql}",
      logoutput   => true,
      refreshonly => $enforce_sql ? {
        true  => false,
        false => true,
      },
    }
  }
}
