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

  $bind_address          = '127.0.0.1'
  $client_package_ensure = 'present'
  $config_template       = 'mysql/my.cnf.erb'
  $default_engine        = 'UNSET'
  $etc_root_password     = false
  $expire_logs_days      = 10
  $key_buffer            = '16M'
  $manage_service        = true
  $max_allowed_packet    = '16M'
  $max_binlog_size       = '100M'
  $max_connections       = 151
  $myisam_recover        = 'BACKUP'
  $old_root_password     = ''
  $package_ensure        = 'present'
  $port                  = 3306
  $purge_conf_dir        = false
  $query_cache_limit     = '1M'
  $query_cache_size      = '16M'
  $restart               = true
  $root_password         = 'UNSET'
  $ssl                   = false
  $thread_cache_size     = 8
  $thread_stack          = '256K'

  # mysql::bindings
  $java_package_ensure   = 'present'
  $perl_package_ensure   = 'present'
  $python_package_ensure = 'present'
  $ruby_package_ensure   = 'present'

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
      if $::operatingsystem == 'Fedora' and $::operatingsystemrelease >= 19 {
        $client_package_name = 'mariadb'
        $server_package_name = 'mariadb-server'
      } else {
        $client_package_name = 'mysql'
        $server_package_name = 'mysql-server'
      }
      $basedir               = '/usr'
      $config_file           = '/etc/my.cnf'
      $datadir               = '/var/lib/mysql'
      $log_error             = '/var/log/mysqld.log'
      $php_package_name      = 'php-mysql'
      $pidfile               = '/var/run/mysqld/mysqld.pid'
      $root_group            = 'root'
      $service_name          = 'mysqld'
      $socket                = '/var/lib/mysql/mysql.sock'
      $ssl_ca                = '/etc/mysql/cacert.pem'
      $ssl_cert              = '/etc/mysql/server-cert.pem'
      $ssl_key               = '/etc/mysql/server-key.pem'
      $tmpdir                = '/tmp'
      # mysql::bindings
      $java_package_name     = 'mysql-connector-java'
      $perl_package_name     = 'perl-DBD-MySQL'
      $python_package_name   = 'MySQL-python'
      $ruby_package_name     = 'ruby-mysql'
      $ruby_package_provider = 'gem'
    }

    'Suse': {
      $basedir               = '/usr'
      $config_file           = '/etc/my.cnf'
      $client_package_name   = $::operatingsystem ? {
        /OpenSuSE/           => 'mysql-community-server-client',
        /(SLES|SLED)/        => 'mysql-client',
        }
      $datadir               = '/var/lib/mysql'
      $log_error             = $::operatingsystem ? {
        /OpenSuSE/           => '/var/log/mysql/mysqld.log',
        /(SLES|SLED)/        => '/var/log/mysqld.log',
      }
      $pidfile               = $::operatingsystem ? {
        /OpenSuSE/           => '/var/run/mysql/mysqld.pid',
        /(SLES|SLED)/        => '/var/lib/mysql/mysqld.pid',
      }
      $root_group            = 'root'
      $server_package_name   = $::operatingsystem ? {
        /OpenSuSE/           => 'mysql-community-server',
        /(SLES|SLED)/        => 'mysql',
      }
      $service_name          = 'mysql'
      $socket                = $::operatingsystem ? {
        /OpenSuSE/           => '/var/run/mysql/mysql.sock',
        /(SLES|SLED)/        => '/var/lib/mysql/mysql.sock',
      }
      $ssl_ca                = '/etc/mysql/cacert.pem'
      $ssl_cert              = '/etc/mysql/server-cert.pem'
      $ssl_key               = '/etc/mysql/server-key.pem'
      $tmpdir                = '/tmp'
      # mysql::bindings
      $java_package_name     = 'mysql-connector-java'
      $perl_package_name     = 'perl-DBD-mysql'
      $python_package_name   = 'python-mysql'
      $ruby_package_name     = $::operatingsystem ? {
        /OpenSuSE/           => 'rubygem-mysql',
        /(SLES|SLED)/        => 'ruby-mysql',
      }
    }

    'Debian': {
      $basedir              = '/usr'
      $client_package_name  = 'mysql-client'
      $config_file          = '/etc/mysql/my.cnf'
      $datadir              = '/var/lib/mysql'
      $log_error            = '/var/log/mysql/error.log'
      $php_package_name     = 'php5-mysql'
      $pidfile              = '/var/run/mysqld/mysqld.pid'
      $root_group           = 'root'
      $server_package_name  = 'mysql-server'
      $service_name         = 'mysql'
      $socket               = '/var/run/mysqld/mysqld.sock'
      $ssl_ca               = '/etc/mysql/cacert.pem'
      $ssl_cert             = '/etc/mysql/server-cert.pem'
      $ssl_key              = '/etc/mysql/server-key.pem'
      $tmpdir                = '/tmp'
      # mysql::bindings
      $java_package_name    = 'libmysql-java'
      $perl_package_name    = 'libdbd-mysql-perl'
      $python_package_name  = 'python-mysqldb'
      $ruby_package_name    = 'libmysql-ruby'
    }

    'FreeBSD': {
      $basedir               = '/usr/local'
      $datadir               = '/var/db/mysql'
      $tmpdir                = '/tmp'
      $service_name          = 'mysql-server'
      $client_package_name   = 'databases/mysql55-client'
      $server_package_name   = 'databases/mysql55-server'
      $socket                = '/tmp/mysql.sock'
      $pidfile               = '/var/db/mysql/mysql.pid'
      $config_file           = '/var/db/mysql/my.cnf'
      $log_error             = "/var/db/mysql/${::hostname}.err"
      $php_package_name      = 'php5-mysql'
      $root_group            = 'wheel'
      $ssl_ca                = undef
      $ssl_cert              = undef
      $ssl_key               = undef
      # mysql::bindings
      $java_package_name     = 'databases/mysql-connector-java'
      $perl_package_name     = 'p5-DBD-mysql'
      $python_package_name   = 'databases/py-MySQLdb'
      $ruby_package_name     = 'ruby-mysql'
      $ruby_package_provider = 'gem'
    }

    default: {
      case $::operatingsystem {
        'Amazon': {
          $basedir               = '/usr'
          $client_package_name   = 'mysql'
          $config_file           = '/etc/my.cnf'
          $datadir               = '/var/lib/mysql'
          $log_error             = '/var/log/mysqld.log'
          $php_package_name      = 'php-mysql'
          $root_group            = 'root'
          $server_package_name   = 'mysql-server'
          $service_name          = 'mysqld'
          $socket                = '/var/lib/mysql/mysql.sock'
          $ssl_ca                = '/etc/mysql/cacert.pem'
          $ssl_cert              = '/etc/mysql/server-cert.pem'
          $ssl_key               = '/etc/mysql/server-key.pem'
          $tmpdir                = '/tmp'
          # mysql::bindings
          $java_package_name     = 'mysql-connector-java'
          $perl_package_name     = 'perl-DBD-MySQL'
          $python_package_name   = 'MySQL-python'
          $ruby_package_name     = 'ruby-mysql'
          $ruby_package_provider = 'gem'
        }

        default: {
          fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat, Debian, and FreeBSD, or operatingsystem Amazon")
        }
      }
    }
  }

}
