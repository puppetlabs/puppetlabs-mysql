# Define: mysql::user
#
# This module creates a user, and uses mysql_password to generate the hash.
# Since it requires class mysql::server, we assume to run all commands as the
# root mysql user against the local mysql server.
#
# Parameters:
#   [*title*]       - mysql user name.
#   [*password*]    - user's password.
#   [*database*]    - database to assign privileges to.
#   [*host*]        - host for assigning privileges to user.
#   [*ensure*]      - specifies if a user is present or absent.
#
# Actions:
#
# Requires:
#
#   class mysql::server
#
# Sample Usage:
#
#  mysql::user { 'username':
#    password => 'password',
#    database => 'database',
#    host     => $::hostname,
#    grant    => ['all']
#  }
#
define mysql::user (
  $password,
  $database,
  $host        = 'localhost',
  $ensure      = 'present'
) {

  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

  if $ensure == 'present' {
    database_user { "${name}@${host}":
      ensure        => $ensure,
      password_hash => mysql_password($password),
      provider      => 'mysql',
      require       => Database[$database],
    }
  } 
}