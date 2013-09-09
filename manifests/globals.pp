# PRIVATE CLASS:  See README.md for more details.
class mysql::globals (
  $override_options = {}
) {

  $default_options = {
    'bind_address'                     => '127.0.0.1',
    'binlog_do_db'                     => 'UNSET',
    'character_set'                    => 'UNSET',
    'default_engine'                   => 'UNSET',
    'etc_root_password'                => false,
    'expire_logs_days'                 => '10',
    'ft_max_word_len'                  => 'UNSET',
    'ft_min_word_len'                  => 'UNSET',
    'key_buffer'                       => '16M',
    'log_bin'                          => 'UNSET',
    'log_bin_trust_function_creators'  => 'UNSET',
    'long_query_time'                  => 'UNSET',
    'manage_config_file'               => true,
    'max_allowed_packet'               => '16M',
    'max_binlog_size'                  => '100M',
    'max_connections'                  => '151',
    'max_heap_table_size'              => 'UNSET',
    'myisam_recover'                   => 'BACKUP',
    'old_root_password'                => '',
    'port'                             => '3306',
    'purge_conf_dir'                   => false,
    'query_cache_limit'                => '1M',
    'query_cache_size'                 => '16M',
    'replicate_ignore_table'           => 'UNSET',
    'replicate_wild_do_table'          => 'UNSET',
    'replicate_wild_ignore_table'      => 'UNSET',
    'restart'                          => true,
    'root_password'                    => 'UNSET',
    'server_id'                        => 'UNSET',
    'sql_log_bin'                      => 'UNSET',
    'ssl'                              => false,
    'table_open_cache'                 => 'UNSET',
    'thread_cache_size'                => '8',
    'thread_stack'                     => '256K',
    'tmp_table_size'                   => 'UNSET',
  }

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
        $distro_options = {
          'basedir'            => '/usr',
          'config_file'        => '/etc/my.cnf',
          'datadir'            => '/var/lib/mysql',
          'log_error'          => '/var/log/mysqld.log',
          'pidfile'            => '/var/run/mysqld/mysqld.pid',
          'root_group'         => 'root',
          'service_name'       => 'mysqld',
          'socket'             => '/var/lib/mysql/mysql.sock',
          'ssl_ca'             => '/etc/mysql/cacert.pem',
          'ssl_cert'           => '/etc/mysql/server-cert.pem',
          'ssl_key'            => '/etc/mysql/server-key.pem',
          'tmpdir'             => '/tmp',
        }
        # mysql::bindings
        $java_package_name     = 'mysql-connector-java'
        $perl_package_name     = 'perl-DBD-MySQL'
        $php_package_name      = 'php-mysql'
        $python_package_name   = 'MySQL-python'
        $ruby_package_name     = 'ruby-mysql'
        $ruby_package_provider = 'gem'
    }

    'Suse': {
      $client_package_name   = $::operatingsystem ? {
        /OpenSuSE/           => 'mysql-community-server-client',
        /(SLES|SLED)/        => 'mysql-client',
      }
      $server_package_name   = $::operatingsystem ? {
        /OpenSuSE/           => 'mysql-community-server',
        /(SLES|SLED)/        => 'mysql',
      }
      $distro_options = {
        'basedir'      => $basedir,
        'config_file'  => '/etc/my.cnf',
        'datadir'      => '/var/lib/mysql',
        'log_error'    => $::operatingsystem ? {
          /OpenSuSE/    => '/var/log/mysql/mysqld.log',
          /(SLES|SLED)/ => '/var/log/mysqld.log',
        },
        'pidfile'       => $::operatingsystem ? {
          /OpenSuSE/    => '/var/run/mysql/mysqld.pid',
          /(SLES|SLED)/ => '/var/lib/mysql/mysqld.pid',
        },
        'root_group'   => 'root',
        'service_name' => 'mysql',
        'socket'       => $::operatingsystem ? {
          /OpenSuSE/           => '/var/run/mysql/mysql.sock',
          /(SLES|SLED)/        => '/var/lib/mysql/mysql.sock',
        },
        'ssl_ca'       => '/etc/mysql/cacert.pem',
        'ssl_cert'     => '/etc/mysql/server-cert.pem',
        'ssl_key'      => '/etc/mysql/server-key.pem',
        'tmpdir'       => '/tmp',
      }
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
      $client_package_name  = 'mysql-client'
      $server_package_name  = 'mysql-server'

      $distro_options = {
        'basedir'      => '/usr',
        'config_file'  => '/etc/mysql/my.cnf',
        'datadir'      => '/var/lib/mysql',
        'log_error'    => '/var/log/mysql/error.log',
        'pidfile'      => '/var/run/mysqld/mysqld.pid',
        'root_group'   => 'root',
        'service_name' => 'mysql',
        'socket'       => '/var/run/mysqld/mysqld.sock',
        'ssl_ca'       => '/etc/mysql/cacert.pem',
        'ssl_cert'     => '/etc/mysql/server-cert.pem',
        'ssl_key'      => '/etc/mysql/server-key.pem',
        'tmpdir'       => '/tmp',
      }
      # mysql::bindings
      $java_package_name    = 'libmysql-java'
      $perl_package_name    = 'libdbd-mysql-perl'
      $php_package_name     = 'php5-mysql'
      $python_package_name  = 'python-mysqldb'
      $ruby_package_name    = 'libmysql-ruby'
    }

    'FreeBSD': {
      $client_package_name   = 'databases/mysql55-client'
      $server_package_name   = 'databases/mysql55-server'
      $distro_options = {
        'basedir'      => '/usr/local',
        'config_file'  => '/var/db/mysql/my.cnf',
        'datadir'      => '/var/db/mysql',
        'log_error'    => "/var/db/mysql/${::hostname}.err",
        'pidfile'      => '/var/db/mysql/mysql.pid',
        'root_group'   => 'wheel',
        'service_name' => 'mysql-server',
        'socket'       => '/tmp/mysql.sock',
        'ssl_ca'       => undef,
        'ssl_cert'     => undef,
        'ssl_key'      => undef,
        'tmpdir'       => '/tmp',
      }
      # mysql::bindings
      $java_package_name     = 'databases/mysql-connector-java'
      $perl_package_name     = 'p5-DBD-mysql'
      $php_package_name      = 'php5-mysql'
      $python_package_name   = 'databases/py-MySQLdb'
      $ruby_package_name     = 'ruby-mysql'
      $ruby_package_provider = 'gem'
    }

    default: {
      case $::operatingsystem {
        'Amazon': {
          $client_package_name   = 'mysql'
          $server_package_name   = 'mysql-server'
          $distro_options = {
            'basedir'      => '/usr',
            'config_file'  => '/etc/my.cnf',
            'datadir'      => '/var/lib/mysql',
            'log_error'    => '/var/log/mysqld.log',
            'pidfile'      => '/var/run/mysqld/mysqld.pid',
            'root_group'   => 'root',
            'service_name' => 'mysqld',
            'socket'       => '/var/lib/mysql/mysql.sock',
            'ssl_ca'       => '/etc/mysql/cacert.pem',
            'ssl_cert'     => '/etc/mysql/server-cert.pem',
            'ssl_key'      => '/etc/mysql/server-key.pem',
            'tmpdir'       => '/tmp',
          }
          # mysql::bindings
          $java_package_name     = 'mysql-connector-java'
          $perl_package_name     = 'perl-DBD-MySQL'
          $php_package_name      = 'php-mysql'
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
  
# Create a merged together set of options.  Rightmost hashes win over left.
$options = merge($default_options, $distro_options, $override_options)

}
