#
class mysql::server::replication {
  $master_slave  = $mysql::server::master_slave
  
  if $mysql::server::replication_enable {
    exec { 'start-service':
      command => '/etc/init.d/mysql start',
      onlyif  => "test `grep -c rpl_semi_sync /usr/my.cnf` != 1",
    }
    
    exec { 'install-replication-plugin':
      command => "mysql -u root -p${::mysql::server::root_password} -e "INSTALL PLUGIN rpl_semi_sync_${mysql::server::master_slave} SONAME 'semisync_${mysql::server::master_slave}.so';",
      path    => '/usr/bin:/bin',
      onlyif  => "test `mysql -u root -p${::mysql::server::root_password} -e "show variables like 'rpl_semi_sync_${mysql::server::master_slave}_enabled';" 2>/dev/null | grep -c ON` != 1",
      require => Exec['start-service'],
    }
  }

}
