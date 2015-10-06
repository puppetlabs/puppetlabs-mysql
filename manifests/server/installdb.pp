#
class mysql::server::installdb {

  if $mysql::server::package_manage {

    # Build the initial databases.
    $mysqluser = $mysql::server::options['mysqld']['user']
    $datadir = $mysql::server::options['mysqld']['datadir']
    $basedir = $mysql::server::options['mysqld']['basedir']
    $config_file = $mysql::server::config_file

    # we should have a (... broken ...) fact 
    if $::mysql_version {

      if versioncmp($::mysql_version, '5.7.6') >= 0 {
        # mysql 5.7.6 introduced mysqld --initialize-insecure
        # (needed to manage passwords later)
        file { '/tmp/mysql-install_validate_password_sql_file.sql':
          ensure  => file,
          content => 'INSERT INTO mysql.plugin (name, dl) VALUES (\'validate_password\', \'validate_password.so\');',
          owner   => $mysqluser,
          group   => 'root',
          mode    => '0500',
          before  => Exec['mysql_install_db'],
        }

        if $mysql::server::manage_config_file {
          $install_db_cmd = "mysqld --defaults-extra-file='${config_file}' --initialize-insecure --basedir='${basedir}' --datadir='${datadir}' --user='${mysqluser}' --init-file='/tmp/mysql-install_validate_password_sql_file.sql'"
        } else {
          $install_db_cmd = "mysqld --initialize-insecure --basedir='${basedir}' --datadir='${datadir}' --user='${mysqluser}' --init-file='/tmp/mysql-install_validate_password_sql_file.sql'"
        }

      } else {
        # older then mysql 5.7.6 
        if $mysql::server::manage_config_file {
          $install_db_cmd = "mysql_install_db --basedir=${basedir} --defaults-extra-file=${config_file} --datadir=${datadir} --user=${mysqluser}"
        } else {
          $install_db_cmd = "mysql_install_db --basedir=${basedir} --datadir=${datadir} --user=${mysqluser}"
        }
      }
    } else {
      # Default, no Version available 
      if $mysql::server::manage_config_file {
        $install_db_cmd = "mysql_install_db --basedir=${basedir} --defaults-extra-file=${config_file} --datadir=${datadir} --user=${mysqluser}"
      } else {
        $install_db_cmd = "mysql_install_db --basedir=${basedir} --datadir=${datadir} --user=${mysqluser}"
      }
    }

    exec { 'mysql_install_db':
      command   => $install_db_cmd,
      creates   => "${datadir}/mysql",
      logoutput => on_failure,
      path      => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
      require   => Package['mysql-server'],
    }

    if $mysql::server::restart {
      Exec['mysql_install_db'] {
        notify => Class['mysql::server::service'],
      }
    }
  }

}
