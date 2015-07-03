#
class mysql::server::replication {
  $master_slave  = $mysql::server::master_slave
  $options       = mysql_deepmerge($mysql::params::default_options, $mysql::server::override_options)

  if $mysql::server::replication_enable {

    exec { 'initial-mysql-config-file':
      command => "echo 'user=mysql' >> /usr/my.cnf; echo 'datadir=/home/mysql/data' >> /usr/my.cnf; echo 'socket=/home/mysql/data/mysql.sock' >> /usr/my.cnf; echo '[mysqld_safe]' >> /usr/my.cnf; echo 'log-error=/home/mysql/log/mysqld.log' >> /usr/my.cnf; echo 'pid-file=/home/mysql/run/mysqld/mysqld.pid' >> /usr/my.cnf",
      unless  => "grep -c rpl_semi_sync /usr/my.cnf",
      path    => '/usr/bin:/bin:/sbin',
    }

    exec { 'start-service':
      command => '/etc/init.d/mysql start',
      path    => '/usr/bin:/bin',
      unless  => "grep -c rpl_semi_sync /usr/my.cnf",
      require => Exec['initial-mysql-config-file'],
    }

    exec { 'install-replication-plugin':
      command => "mysql -u root -e \"INSTALL PLUGIN rpl_semi_sync_${mysql::server::master_slave} SONAME 'semisync_${mysql::server::master_slave}.so';\"",
      path    => '/usr/bin:/bin',
      unless  => "mysql -u root -e \"show variables like 'rpl_semi_sync_${mysql::server::master_slave}_enabled';\" | grep rpl_semi | grep -c ON",
      require => Exec['start-service'],
    }
  }

}
