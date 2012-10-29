# Class: mysql::params
#
#   The mysql configuration settings.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::params {

  $bind_address                   = '127.0.0.1'
  $port                           = 3306
  $etc_root_password              = false
  $ssl                            = false
  $restart                        = true
  $slow_query_log_file            = false
  $long_query_time                = 10
  $read_only                      = false
  $replication_enabled            = false
  $expire_logs_days               = '10'
  $max_binlog_size                = '100M'
  $max_allowed_packet             = '16M'
  $auto_increment_increment       = '10'
  $replicate_ignore_table         = []
  $replicate_ignore_db            = []
  $replicate_do_table             = []
  $replicate_do_db                = []
  $innodb_file_per_table          = '1'
  $innodb_flush_log_at_trx_commit = '0'
  $innodb_buffer_pool_size        = '512M'
  $innodb_status_file             = '0'
  $innodb_support_xa              = '1'
  $innodb_log_file_size           = '5M'
  $innodb_flush_method            = ''
  $innodb_thread_concurrency      = '8'
  $innodb_concurrency_tickets     = '500'
  $innodb_doublewrite             = '1'
  $ft_min_word_len                = '5'
  $extra_configs                  = {}

  case $::operatingsystem {
    'Ubuntu': {
      $service_provider = upstart
    }
    default: {
      $service_provider = undef
    }
  }

  case $::osfamily {
    'RedHat': {
      $basedir               = '/usr'
      $datadir               = '/var/lib/mysql'
      $service_name          = 'mysqld'
      $client_package_name   = 'mysql'
      $server_package_name   = 'mysql-server'
      $ius_client_packages   = ['mysql55','mysqlclient16','mysql55-libs']
      $ius_client_package_excludes = ['mysql','mysql-libs','mysql-server','mysql-devel','mysql-test','mysql-embedded','mysql-embedded-devel']
      $ius_server_packages   = ['mysql55-server',$ius_client_packages]
      $socket                = '/var/lib/mysql/mysql.sock'
      $pidfile               = '/var/run/mysqld/mysqld.pid'
      $config_file           = '/etc/my.cnf'
      $log_error             = '/var/log/mysqld.log'
      $ruby_package_name     = 'ruby-mysql'
      $ruby_package_provider = 'gem'
      $python_package_name   = 'MySQL-python'
      $java_package_name     = 'mysql-connector-java'
      $root_group            = 'root'
      $ssl_ca                = '/etc/mysql/cacert.pem'
      $ssl_cert              = '/etc/mysql/server-cert.pem'
      $ssl_key               = '/etc/mysql/server-key.pem'
    }

    'Debian': {
      $basedir              = '/usr'
      $datadir              = '/var/lib/mysql'
      $service_name         = 'mysql'
      $client_package_name  = 'mysql-client'
      $server_package_name  = 'mysql-server'
      $socket               = '/var/run/mysqld/mysqld.sock'
      $pidfile              = '/var/run/mysqld/mysqld.pid'
      $config_file          = '/etc/mysql/my.cnf'
      $log_error            = '/var/log/mysql/error.log'
      $ruby_package_name    = 'libmysql-ruby'
      $python_package_name  = 'python-mysqldb'
      $java_package_name    = 'libmysql-java'
      $root_group           = 'root'
      $ssl_ca               = '/etc/mysql/cacert.pem'
      $ssl_cert             = '/etc/mysql/server-cert.pem'
      $ssl_key              = '/etc/mysql/server-key.pem'
    }

    'FreeBSD': {
      $basedir               = '/usr/local'
      $datadir               = '/var/db/mysql'
      $service_name          = 'mysql-server'
      $client_package_name   = 'databases/mysql55-client'
      $server_package_name   = 'databases/mysql55-server'
      $socket                = '/tmp/mysql.sock'
      $pidfile               = '/var/db/mysql/mysql.pid'
      $config_file           = '/var/db/mysql/my.cnf'
      $log_error             = "/var/db/mysql/${::hostname}.err"
      $ruby_package_name     = 'ruby-mysql'
      $ruby_package_provider = 'gem'
      $python_package_name   = 'databases/py-MySQLdb'
      $java_package_name     = 'databases/mysql-connector-java'
      $root_group            = 'wheel'
      $ssl_ca                = undef
      $ssl_cert              = undef
      $ssl_key               = undef
    }

    default: {
      case $::operatingsystem {
        'Amazon': {
          $basedir               = '/usr'
          $datadir               = '/var/lib/mysql'
          $service_name          = 'mysqld'
          $client_package_name   = 'mysql'
          $server_package_name   = 'mysql-server'
          $socket                = '/var/lib/mysql/mysql.sock'
          $config_file           = '/etc/my.cnf'
          $log_error             = '/var/log/mysqld.log'
          $ruby_package_name     = 'ruby-mysql'
          $ruby_package_provider = 'gem'
          $python_package_name   = 'MySQL-python'
          $java_package_name     = 'mysql-connector-java'
          $root_group            = 'root'
          $ssl_ca                = '/etc/mysql/cacert.pem'
          $ssl_cert              = '/etc/mysql/server-cert.pem'
          $ssl_key               = '/etc/mysql/server-key.pem'
        }

        default: {
          fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat, Debian, and FreeBSD, or operatingsystem Amazon")
        }
      }
    }
  }

}
