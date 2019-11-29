# @summary
#   Builds initial databases on installation.
#
# @api private
#
class mysql::server::installdb {
  $options = $mysql::server::options

  if $mysql::server::package_manage {

    # Build the initial databases.
    $mysqluser = $mysql::server::options['mysqld']['user']
    $datadir = $mysql::server::options['mysqld']['datadir']
    $basedir = $mysql::server::options['mysqld']['basedir']
    $config_file = $mysql::server::config_file
    $log_error = $mysql::server::options['mysqld']['log-error']

    if $mysql::server::manage_config_file and $config_file != $mysql::params::config_file {
      $_config_file=$config_file
    } else {
      $_config_file=undef
    }

    # create the folder for the logfile
    if dirname($options['mysqld']['log-error']) or $options['mysqld_safe']['log-error']{
      file { dirname($options['mysqld']['log-error']):
        ensure => directory,
        owner  => $mysqluser,
        group  => $::mysql::server::mysql_group,
        mode   => 'u+rw',
        before => Mysql_datadir[ $datadir ],
      }
    }

    # create the folder for the pid-file
    if $options['mysqld']['pid-file'] {
      file { dirname($options['mysqld']['pid-file']):
        ensure => directory,
        owner  => $mysqluser,
        group  => $::mysql::server::mysql_group,
        mode   => 'u+rw',
        before => Mysql_datadir[ $datadir ],
      }
    }

    mysql_datadir { $datadir:
      ensure              => 'present',
      datadir             => $datadir,
      basedir             => $basedir,
      user                => $mysqluser,
      log_error           => $log_error,
      defaults_extra_file => $_config_file,
    }

    if $mysql::server::restart {
      Mysql_datadir[$datadir] {
        notify => Class['mysql::server::service'],
      }
    }
  }

}
