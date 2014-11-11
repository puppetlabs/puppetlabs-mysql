#
class mysql::server::install {

  package { 'mysql-server':
    ensure          => $mysql::server::package_ensure,
    install_options => $mysql::server::install_options,
    name            => $mysql::server::package_name,
  }

  # Build the initial databases.
  if $mysql::server::override_options['mysqld'] and $mysql::server::override_options['mysqld']['datadir'] {
    $mysqluser = $mysql::server::options['mysqld']['user']
    $datadir = $mysql::server::override_options['mysqld']['datadir']

    exec { 'mysql_install_db':
      command   => "mysql_install_db --datadir=${datadir} --user=${mysqluser}",
      creates   => "${datadir}/mysql",
      logoutput => on_failure,
      path      => '/bin:/sbin:/usr/bin:/usr/sbin',
      require   => Package['mysql-server'],
    }

    if $mysql::server::restart {
      Exec['mysql_install_db'] {
        notify => Class['mysql::server::service'],
      }
    }
  }

}
