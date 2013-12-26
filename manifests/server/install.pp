#
class mysql::server::install {

  package { 'mysql-server':
    ensure => $mysql::server::package_ensure,
    name   => $mysql::server::package_name,
  }

  # run mysql_install_db if datadir is set and datadir doesn't contain the
  # mysql database (directory)
  if $mysql::server::override_options['mysqld'] and $mysql::server::override_options['mysqld']['datadir'] {
    $mysqluser = $mysql::server::options['mysqld']['user']
    $datadir = $mysql::server::override_options['mysqld']['datadir']

    exec { "mysql_install_db":
      command => "mysql_install_db --datadir=$datadir --user=$mysqluser",
      creates => "$datadir/mysql",
      logoutput => on_failure,
    }
  }

}
