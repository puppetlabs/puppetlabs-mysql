# Define: mysql::db
#
# This module creates database instances, a user, and grants that user
# privileges to the database.  It can also import SQL from a file in order to,
# for example, initialize a database schema.
#
# Since it requires class mysql::server, we assume to run all commands as the
# root mysql user against the local mysql server.
#
# Parameters:
#   [*title*]       - mysql database name.
#   [*user*]        - username to create and grant access.
#   [*password*]    - user's password.
#   [*collate*]     - database charset.
#   [*charset*]     - database charset.
#   [*host*]        - host for assigning privileges to user.
#   [*grant*]       - array of privileges to grant user.
#   [*enforce_sql*] - whether to enforce or conditionally run sql on creation.
#   [*sql*]         - sql statement to run.
#   [*ensure*]      - specifies if a database is present or absent.
#
# Actions:
#
# Requires:
#
#   class mysql::server
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
  $charset     = 'utf8',
  $collate     = 'utf8_general_ci',
  $host        = 'localhost',
  $grant       = 'ALL',
  $sql         = '',
  $enforce_sql = false,
  $ensure      = 'present'
) {
  #input validation
  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")
  $table = "${name}.*"

  mysql_database { $name:
    ensure   => $ensure,
    charset  => $charset,
    collate  => $collate,
    provider => 'mysql',
    require  => [Class['mysql::server'],Package['mysql_client']],
    before   => Mysql_user["${user}@${host}"],
  }

  $user_resource = {
    ensure        => $ensure,
    password_hash => mysql_password($password),
    provider      => 'mysql'
  }
  ensure_resource('mysql_user', "${user}@${host}", $user_resource)

  if $ensure == 'present' {
    mysql_grant { "${user}@${host}/${table}":
      privileges => $grant,
      provider   => 'mysql',
      user       => "${user}@${host}",
      table      => $table,
      require    => Mysql_user["${user}@${host}"],
    }

    $refresh = ! $enforce_sql

    if $sql {
      exec{ "${name}-import":
        command     => "/usr/bin/mysql ${name} < ${sql}",
        logoutput   => true,
        environment => "HOME=${::root_home}",
        refreshonly => $refresh,
        require     => Mysql_grant["${user}@${host}/${table}"],
        subscribe   => Mysql_database[$name],
      }
    }
  }
}
