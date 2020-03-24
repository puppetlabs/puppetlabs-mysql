# @summary
#   Binary log configuration requires the mysql user to be present. This must be done after package install
#
# @api private
#
class mysql::server::managed_dirs {

  $options = $mysql::server::_options
  $includedir = $mysql::server::includedir
  $managed_dirs = $mysql::server::managed_dirs

  #Debian: Fix permission on directories
  if $managed_dirs {
    $managed_dirs.each | $entry | {
      $dir = $options['mysqld']["${entry}"]
      if ( $dir and $dir != '/usr' and $dir != '/tmp' ) {
        file {"${entry}-managed_dir":
          ensure => directory,
          path   => $dir,
          mode   => '0700',
          owner  => $options['mysqld']['user'],
          group  => $options['mysqld']['user'],
        }
      }
    }
  }

  $logbin = pick($options['mysqld']['log-bin'], $options['mysqld']['log_bin'], false)

  if $logbin {
    $logbindir = dirname($logbin)

    #Stop puppet from managing directory if just a filename/prefix is specified
    if $logbindir != '.' {
      file { $logbindir:
        ensure => directory,
        mode   => '0700',
        owner  => $options['mysqld']['user'],
        group  => $options['mysqld']['user'],
      }
    }
  }
}
