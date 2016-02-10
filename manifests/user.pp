# See README.md for details.
define mysql::user (
  $user           = $name,
  $password,
  $dbname,
  $charset        = 'utf8',
  $collate        = 'utf8_general_ci',
  $host           = 'localhost',
  $grant          = 'ALL',
  $grant_options  = undef,
  $ensure         = 'present',
) {
  #input validation
  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")
  $table = "${dbname}.*"

  include '::mysql::client'

  anchor{"mysql::user_${name}::begin": }->
  Class['::mysql::client']->
  anchor{"mysql::user_${name}::end": }

  $user_resource = {
    ensure        => $ensure,
    password_hash => mysql_password($password),
  }
  ensure_resource('mysql_user', "${user}@${host}", $user_resource)

  if $ensure == 'present' {
    mysql_grant { "${user}@${host}/${table}":
      privileges => $grant,
      options    => $grant_options,
      user       => "${user}@${host}",
      table      => $table,
      require    => [
        Mysql_user["${user}@${host}"],
      ],
    }

  }
}
