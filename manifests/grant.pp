# Define: mysql::grant
#
# This module creates a grant to a user and a db
# Since it requires class mysql::server, we assume to run all commands as the
# root mysql user against the local mysql server.
#
# Parameters:
#   [*title*]       - prettyname for this grant.
#   [*database*]    - database to assign privileges to.
#   [*host*]        - host for assigning privileges to user.
#   [*user*]        - the user we're providing the grant to.
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
#  mysql::grant { 'username':
#    password => 'password',
#    database => 'database',
#    host     => $::hostname,
#    grant    => ['all']
#  }
#
define mysql::grant (
  $user,
  $database,
  $grant,
  $host        = 'localhost',
  $ensure      = 'present'
) {

  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

  if $ensure == 'present' {
    database_grant { "${user}@${host}/${database}":
      privileges => $grant,
      provider   => 'mysql',
      require    => Database_user["${user}@${host}"],
    }
  } 
}
