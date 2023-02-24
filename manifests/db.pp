# @summary
#   Create and configure a MySQL database.
#
# @example Create a database
#   mysql::db { 'mydb':
#     user     => 'myuser',
#     password => 'mypass',
#     host     => 'localhost',
#     grant    => ['SELECT', 'UPDATE'],
#   }
#
# @param name
#   The name of the database to create. Database names must:
#     * be longer than 64 characters.
#     * not contain / \ or . characters.
#     * not contain characters that are not permitted in file names.
#     * not end with space characters.
# @param user
#   The user for the database you're creating.
# @param password
#   The password for $user for the database you're creating.
# @param tls_options
#   The tls_options for $user for the database you're creating.
# @param dbname
#   The name of the database to create.
# @param charset
#   The character set for the database. Must have the same value as collate to avoid corrective changes. See https://dev.mysql.com/doc/refman/8.0/en/charset-mysql.html for charset and collation pairs.
# @param collate
#   The collation for the database. Must have the same value as charset to avoid corrective changes. See https://dev.mysql.com/doc/refman/8.0/en/charset-mysql.html for charset and collation pairs.
# @param host
#   The host to use as part of user@host for grants.
# @param grant
#   The privileges to be granted for user@host on the database.
# @param grant_options
#   The grant_options for the grant for user@host on the database.
# @param sql
#   The path to the sqlfile you want to execute. This can be an array containing one or more file paths.
# @param enforce_sql
#   Specifies whether executing the sqlfiles should happen on every run. If set to false, sqlfiles only run once.
# @param ensure
#   Specifies whether to create the database. Valid values are 'present', 'absent'. Defaults to 'present'.
# @param import_timeout
#   Timeout, in seconds, for loading the sqlfiles. Defaults to 300.
# @param import_cat_cmd
#   Command to read the sqlfile for importing the database. Useful for compressed sqlfiles. For example, you can use 'zcat' for .gz files.
# @param mysql_exec_path
#   Specify the path in which mysql has been installed if done in the non-standard bin/sbin path.   
#
define mysql::db (
  String[1]                                      $user,
  Variant[String, Sensitive[String]]             $password,
  Optional[Array[String[1]]]                     $tls_options     = undef,
  String                                         $dbname          = $name,
  String[1]                                      $charset         = 'utf8',
  String[1]                                      $collate         = 'utf8_general_ci',
  String[1]                                      $host            = 'localhost',
  Variant[String[1], Array[String[1]]]           $grant           = 'ALL',
  Optional[Variant[String[1], Array[String[1]]]] $grant_options   = undef,
  Optional[Array]                                $sql             = undef,
  Boolean                                        $enforce_sql     = false,
  Enum['absent', 'present']                      $ensure          = 'present',
  Integer                                        $import_timeout  = 300,
  Enum['cat', 'zcat', 'bzcat']                   $import_cat_cmd  = 'cat',
  Optional[String]                               $mysql_exec_path = undef,
) {
  include 'mysql::client'

  # Ensure that the database name is valid.
  if $dbname !~ /^[^\/?%*:|\""<>.\s;]{1,64}$/ {
    $message = "The database name '${dbname}' is invalid. Values must:
      * be longer than 64 characters.
      * not contain // \\ or . characters.
      * not contain characters that are not permitted in file names.
      * not end with space characters."
    fail($message)
  }

  # Ensure that the sql files passed are valid file paths.
  if $sql {
    $sql.each | $sqlfile | {
      if $sqlfile !~ /^\/(?:.[.A-Za-z0-9_-]+\/?+)+(?:\.[.A-Za-z0-9]+)+$/ {
        $message = "The file '${sqlfile}' is invalid. A valid file path is expected."
        fail($message)
      }
    }
  }

  if ($mysql_exec_path) {
    $_mysql_exec_path = $mysql_exec_path
  } else {
    $_mysql_exec_path = $mysql::params::exec_path
  }

  $db_resource = {
    ensure   => $ensure,
    charset  => $charset,
    collate  => $collate,
    provider => 'mysql',
    require  => [Class['mysql::client']],
  }
  ensure_resource('mysql_database', $dbname, $db_resource)

  $user_resource = {
    ensure        => $ensure,
    password_hash => mysql::password($password),
    tls_options   => $tls_options,
  }
  ensure_resource('mysql_user', "${user}@${host}", $user_resource)

  if $ensure == 'present' {
    $table = "${dbname}.*"

    mysql_grant { "${user}@${host}/${table}":
      privileges => $grant,
      provider   => 'mysql',
      user       => "${user}@${host}",
      table      => $table,
      options    => $grant_options,
      require    => [
        Mysql_database[$dbname],
        Mysql_user["${user}@${host}"],
      ],
    }

    if $sql {
      exec { "${dbname}-import":
        command     => "${import_cat_cmd} ${shell_join($sql)} | mysql ${dbname}",
        logoutput   => true,
        environment => "HOME=${facts['root_home']}",
        refreshonly => ! $enforce_sql,
        path        => "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:${_mysql_exec_path}",
        require     => Mysql_grant["${user}@${host}/${table}"],
        subscribe   => Mysql_database[$dbname],
        timeout     => $import_timeout,
      }
    }
  }
}
