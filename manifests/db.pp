# See README.md for details.
define mysql::db (
  $user,
  $password,
  $dbname         = $name,
  $charset        = 'utf8',
  $collate        = 'utf8_general_ci',
  $host           = 'localhost',
  $grant          = 'ALL',
  $sql            = undef,
  $enforce_sql    = false,
  $ensure         = 'present',
  $import_timeout = 300,
) {
  
  # JOE
  if $::osfamily == 'Windows' {
    Exec { provider => 'cygwin' }
    # Use native mysql client command that is shipped with the Chococaley package. Alternatively 
    # we could install the Cygwin package, but we would need to make sure we used same versions for best practise.
    # TODO: Earlier I didn't need to hardcode the path.
    $mysql_command = 'C:/tools/mysql/current/bin/mysql'
  } else { 
    Exec { provider => 'posix' } 
    $mysql_command = '/usr/bin/mysql'
  }
  $mysql_service = Class['mysql::server']
    
  #input validation
  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")
  $table = "${dbname}.*"

  if !(is_array($sql) or is_string($sql)) {
    fail('$sql must be either a string or an array.')
  }

  $sql_inputs = join([$sql], ' ')

  include '::mysql::client'

  # JOE
  # To avoid:
  # Error: Could not apply complete catalog: Found 1 dependency cycle:
	# (Anchor[mysql::db_jackrabbit::begin] => Class[Mysql::Client] => Class[Mysql::Client] => Anchor[mysql::db_repository::end] => Mysql::Db[repository] => Mysql::Db[jackrabbit] => Anchor[mysql::db_jackrabbit::begin])
  anchor{"mysql::db_${name}::begin": }->
  #Class['::mysql::client']->
  anchor{"mysql::db_${name}::end": }

  $db_resource = {
    ensure   => $ensure,
    charset  => $charset,
    collate  => $collate,
    provider => 'mysql',
    require  => [ Class['mysql::client'] ],
  }
  ensure_resource('mysql_database', $dbname, $db_resource)

  $user_resource = {
    ensure        => $ensure,
    password_hash => mysql_password($password),
    provider      => 'mysql',
  }
  ensure_resource('mysql_user', "${user}@${host}", $user_resource)

  if $ensure == 'present' {
    mysql_grant { "${user}@${host}/${table}":
      privileges => $grant,
      provider   => 'mysql',
      user       => "${user}@${host}",
      table      => $table,
      require    => [
        Mysql_database[$dbname],
        Mysql_user["${user}@${host}"],
      ],
    }

    $refresh = ! $enforce_sql

    if $sql {
      if $::osfamily == 'Windows' {
				exec{ "${dbname}-import":
					command     => "$mysql_command ${dbname} < ${sql_inputs}",
					logoutput   => true,
					# TODO: Warning: Exec[quartz-import](provider=cygwin): Cannot understand environment setting "HOME="
					environment => "HOME=${::root_home}",
					refreshonly => $refresh,
					path        => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
					require     => Mysql_grant["${user}@${host}/${table}"],
					subscribe   => Mysql_database[$dbname],
					timeout     => $import_timeout,
				}
			} else { 
				exec{ "${dbname}-import":
					command     => "cat ${sql_inputs} | mysql ${dbname}",
					logoutput   => true,
					environment => "HOME=${::root_home}",
					refreshonly => $refresh,
					path        => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
					require     => Mysql_grant["${user}@${host}/${table}"],
					subscribe   => Mysql_database[$dbname],
					timeout     => $import_timeout,
				}
			}
    }
  }
}
