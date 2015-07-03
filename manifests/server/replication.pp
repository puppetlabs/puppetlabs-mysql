#
class mysql::server::replication {
  $master_slave  = $mysql::server::master_slave
  $server_id     = $mysql::server::rep_server_id

  if $mysql::server::replication_enable {
    
    exec { 'install-replication-plugin':
      command => "mysql -u root -e \"INSTALL PLUGIN rpl_semi_sync_${mysql::server::master_slave} SONAME 'semisync_${mysql::server::master_slave}.so';\"",
      path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
      onlyif  => "test `grep -c rpl_semi_sync /usr/my.cnf` != 1",
    }

    ini_setting { "server-id":
      ensure  => present,
      path    => '/usr/my.cnf',
      section => 'mysqld',
      setting => 'server-id',
      value   => $server_id,
      require => Exec['install-replication-plugin'],
      notify  => Exec['restart-service'],
    }
    
    ini_setting { "rpl_semi_sync_master":
      ensure  => present,
      path    => '/usr/my.cnf',
      section => 'mysqld',
      setting => "rpl_semi_sync_${master_slave}_enabled",
      value   => '1',
      require => Exec['install-replication-plugin'],
      notify  => Exec['restart-service'],
    }
    
    exec { 'restart-service':
      command     => '/etc/init.d/mysql restart',
      path        => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
      refreshonly => true,
    }
  }

}
