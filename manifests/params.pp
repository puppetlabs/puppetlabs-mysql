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
  $slow_query_log_file            = false
  $long_query_time                = 10
  $character_set_server           = 'utf8'
  $collation_server               = 'utf8_general_ci'
  $ft_min_word_len                = 3
  $tmp_table_size                 = '16M'
  $max_heap_table_size            = '16M'
  $max_tmp_tables                 = '32'
  $join_buffer_size               = '3M'
  $read_buffer_size               = '4M'
  $sort_buffer_size               = '4M'
  $table_cache                    = '64'
  $table_definition_cache         = '256'
  $open_files_limit               = '1024'
  $thread_stack                   = '192K'
  $thread_cache_size              = '8'
  $thread_concurrency             = '10'
  $query_cache_size               = '16M'
  $query_cache_limit              = '1M'
  $tmp_table_size                 = '16M'
  $read_rnd_buffer_size           = '256K'
  $key_buffer_size                = '16M'
  $myisam_sort_buffer_size        = '8M'
  $myisam_max_sort_file_size      = '512M'
  $myisam_recover                 = 'BACKUP'
  $max_allowed_packet             = "16M"
  $max_connections                = '151'
  $wait_timeout                   = "28800"
  $connect_timeout                = "10"
  $innodb_file_per_table          = '1'
  $innodb_status_file             = '0'
  $innodb_support_xa              = '0'
  $innodb_flush_log_at_trx_commit = '0'
  $innodb_buffer_pool_size        = '8M'
  $innodb_log_file_size           = '5M'
  $innodb_flush_method            = 'O_DIRECT'
  $innodb_thread_concurrency      = '8'
  $innodb_concurrency_tickets     = '500'
  $innodb_doublewrite             = '1'
  $read_only                      = false
  $replication_enabled            = false
  $expire_logs_days               = '10'
  $max_binlog_size                = '100M'
  $replicate_ignore_table         = []
  $replicate_ignore_db            = []
  $replicate_do_table             = []
  $replicate_do_db                = []
  $extra_configs                  = {}

  case $::operatingsystem {
    "Ubuntu": {
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

    'Debian': {
      $basedir              = '/usr'
      $datadir              = '/var/lib/mysql'
      $service_name         = 'mysql'
      $client_package_name  = 'mysql-client'
      $server_package_name  = 'mysql-server'
      $socket               = '/var/run/mysqld/mysqld.sock'
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
