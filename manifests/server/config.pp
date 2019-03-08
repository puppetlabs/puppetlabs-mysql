# @summary
#   Private class for MySQL server configuration.
#
# @api private
#
class mysql::server::config {

  $options = $mysql::server::options
  $includedir = $mysql::server::includedir

  File {
    owner  => 'root',
    group  => $mysql::server::root_group,
    mode   => '0400',
  }

  if $includedir and $includedir != '' {
    file { $includedir:
      ensure  => directory,
      mode    => '0755',
      recurse => $mysql::server::purge_conf_dir,
      purge   => $mysql::server::purge_conf_dir,
    }

    # on some systems this is /etc/my.cnf.d, while Debian has /etc/mysql/conf.d and FreeBSD something in /usr/local. For the latter systems,
    # managing this basedir is also required, to have it available before the package is installed.
    $includeparentdir = dirname($includedir)
    if $includeparentdir != '/' and $includeparentdir != '/etc' {
      file { $includeparentdir:
        ensure => directory,
        mode   => '0755',
      }
    }
  }

  if $mysql::server::manage_config_file  {
    file { 'mysql-config-file':
      path                    => $mysql::server::config_file,
      content                 => template('mysql/my.cnf.erb'),
      mode                    => '0644',
      selinux_ignore_defaults => true,
    }

    # on mariadb systems, $includedir is not defined, but /etc/my.cnf.d has
    # to be managed to place the server.cnf there
    $configparentdir = dirname($mysql::server::config_file)
    # Before setting $configparentdir we first check to make sure that it's value is valid
    if $configparentdir != '/' and $configparentdir != '/etc' {
      # We then check that the value of $includedir is either undefined or that different from $configparentdir
      # We first check that it is undefined due to dirname throwing an error when given undef/empty strings
      if $includedir == undef or $includedir == '' or
        ($configparentdir != $includedir and $configparentdir != dirname($includedir)) {
        file { $configparentdir:
          ensure => directory,
          mode   => '0755',
        }
      }
    }
  }

  if $options['mysqld']['ssl-disable'] {
    notify {'ssl-disable':
      message =>'Disabling SSL is evil! You should never ever do this except
                if you are forced to use a mysql version compiled without SSL support'
    }
  }
}
