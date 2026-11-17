# @summary
#   Builds initial databases on installation.
#
# @api private
#
class mysql::server::installdb {
  $options = $mysql::server::_options

  if $mysql::server::package_manage {
    # Build the initial databases.
    $mysqluser = $mysql::server::_options['mysqld']['user']
    $datadir = $mysql::server::_options['mysqld']['datadir']
    $basedir = $mysql::server::_options['mysqld']['basedir']
    $config_file = $mysql::server::config_file
    $log_error = $mysql::server::_options['mysqld']['log-error']

    if $mysql::server::manage_config_file and $config_file != $mysql::params::config_file {
      $_config_file=$config_file
    } else {
      $_config_file=undef
    }

    if $log_error {
      # Most packages create the directory the error log lives in (/var/log/mariadb, /var/log/mysql), Debian 12
      # does not. Manage whichever directory log-error points into, but never /var/log itself.
      $log_dir = dirname($log_error)

      # mysql::server::managed_dirs already manages the directory of log-bin and every $managed_dirs entry. When
      # log-error lives in one of those, declaring the directory here as well is a duplicate resource.
      $log_bin = pick($mysql::server::_options['mysqld']['log-bin'], $mysql::server::_options['mysqld']['log_bin'], false)
      $log_bin_dir = $log_bin ? {
        false   => undef,
        default => dirname($log_bin),
      }
      $managed_dirs_path = pick($mysql::server::managed_dirs, []).map |$entry| {
        $mysql::server::_options['mysqld'][$entry]
      }
      $managed_elsewhere = $log_dir in ([$log_bin_dir] + $managed_dirs_path)

      if $log_dir != '/var/log' and !$managed_elsewhere {
        file { $log_dir:
          ensure => 'directory',
          owner  => $mysqluser,
          group  => $mysql::server::mysql_group,
          before => File[$log_error],
        }
      }

      file { $log_error:
        ensure => file,
        owner  => $mysqluser,
        group  => $mysql::server::mysql_group,
        mode   => 'u+rw',
        before => Mysql_datadir[$datadir],
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
