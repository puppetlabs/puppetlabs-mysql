# Class: mysql::config
#
# Parameters:
#
#   [*root_password*]     - root user password.
#   [*old_root_password*] - previous root user password,
#   [*bind_address*]      - address to bind service.
#   [*port*]              - port to bind service.
#   [*etc_root_password*] - whether to save /etc/.my.cnf.
#   [*service_name*]      - mysql service name.
#   [*config_file*]       - my.cnf configuration file path.
#   [*socket*]            - mysql socket.
#   [*datadir*]           - path to datadir.
#   [*ssl]                - enable ssl
#   [*ssl_ca]             - path to ssl-ca
#   [*ssl_cert]           - path to ssl-cert
#   [*ssl_key]            - path to ssl-key
#
# Actions:
#
# Requires:
#
#   class mysql::server
#
# Usage:
#
#   class { 'mysql::config':
#     root_password => 'changeme',
#     bind_address  => $::ipaddress,
#   }
#
class mysql::config(
  $root_password          = 'UNSET',
  $old_root_password      = '',
  $bind_address           = $mysql::params::bind_address,
  $port                   = $mysql::params::port,
  $etc_root_password      = $mysql::params::etc_root_password,
  $service_name           = $mysql::params::service_name,
  $config_file            = $mysql::params::config_file,
  $socket                 = $mysql::params::socket,
  $datadir                = $mysql::params::datadir,
  $ssl                    = $mysql::params::ssl,
  $ssl_ca                 = $mysql::params::ssl_ca,
  $ssl_cert               = $mysql::params::ssl_cert,
  $ssl_key                = $mysql::params::ssl_key,
  $log_error              = $mysql::params::log_error,
  $slow_query_log_file    = $mysql::params::slow_query_log_file,
  $long_query_time        = $mysql::params::long_query_time,
  $character_set_server   = $mysql::params::character_set_server,
  $collation_server       = $mysql::params::collation_server,
  $tmp_table_size         = $mysql::params::tmp_table_size,
  $max_heap_table_size    = $mysql::params::max_heap_table_size,
  $max_tmp_tables         = $mysql::params::max_tmp_tables,
  $join_buffer_size       = $mysql::params::join_buffer_size,
  $read_buffer_size       = $mysql::params::read_buffer_size,
  $sort_buffer_size       = $mysql::params::sort_buffer_size,
  $table_cache            = $mysql::params::table_cache,
  $table_definition_cache = $mysql::params::table_definition_cache,
  $open_files_limit       = $mysql::params::open_files_limit,
  $thread_stack           = $mysql::params::thread_stack,
  $thread_cache_size      = $mysql::params::thread_cache_size,
  $thread_concurrency     = $mysql::params::thread_concurrency,
  $query_cache_size       = $mysql::params::query_cache_size,
  $query_cache_limit      = $mysql::params::query_cache_limit,
  $tmp_table_size         = $mysql::params::tmp_table_size,
  $read_rnd_buffer_size   = $mysql::params::read_rnd_buffer_size,
  $max_allowed_packet     = $mysql::params::max_allowed_packet,
  $max_connections        = $mysql::params::max_connections,
  $wait_timeout           = $mysql::params::wait_timeout,
  $connect_timeout        = $mysql::params::connect_timeout,
  $innodb_file_per_table  = $mysql::params::innodb_file_per_table,
  $innodb_status_file     = $mysql::params::innodb_status_file,
  $innodb_support_xa      = $mysql::params::innodb_support_xa,
  $read_only              = $mysql::params::read_only,
  $replication_enabled    = $mysql::params::replication_enabled,
  $expire_logs_days       = $mysql::params::expire_logs_days,
  $max_binlog_size        = $mysql::params::max_binlog_size,
  $replicate_ignore_table = $mysql::params::replicate_ignore_table,
  $replicate_ignore_db    = $mysql::params::replicate_ignore_db,
  $replicate_do_table     = $mysql::params::replicate_do_table,
  $replicate_do_db        = $mysql::params::replicate_do_db,
  $extra_configs          = $mysql::params::extra_configs,
  $default_engine         = 'UNSET',
  $root_group             = $mysql::params::root_group,

  $key_buffer_size                = $mysql::params::key_buffer_size,
  $myisam_sort_buffer_size        = $mysql::params::myisam_sort_buffer_size,
  $myisam_max_sort_file_size      = $mysql::params::myisam_max_sort_file_size,
  $myisam_recover                 = $mysql::params::myisam_recover,
  $innodb_flush_log_at_trx_commit = $mysql::params::innodb_flush_log_at_trx_commit,
  $innodb_buffer_pool_size        = $mysql::params::innodb_buffer_pool_size,
  $innodb_log_file_size           = $mysql::params::innodb_log_file_size,
  $innodb_flush_method            = $mysql::params::innodb_flush_method,
  $innodb_thread_concurrency      = $mysql::params::innodb_thread_concurrency,
  $innodb_concurrency_tickets     = $mysql::params::innodb_concurrency_tickets,
  $innodb_doublewrite             = $mysql::params::innodb_doublewrite,
) inherits mysql::params {

  File {
    owner  => 'root',
    group  => $root_group,
    mode   => '0400',
    notify => Exec['mysqld-restart'],
  }

  if $ssl and $ssl_ca == undef {
    fail('The ssl_ca parameter is required when ssl is true')
  }

  if $ssl and $ssl_cert == undef {
    fail('The ssl_cert parameter is required when ssl is true')
  }

  if $ssl and $ssl_key == undef {
    fail('The ssl_key parameter is required when ssl is true')
  }

  # This kind of sucks, that I have to specify a difference resource for
  # restart.  the reason is that I need the service to be started before mods
  # to the config file which can cause a refresh
  exec { 'mysqld-restart':
    command     => "service ${service_name} restart",
    logoutput   => on_failure,
    refreshonly => true,
    path        => '/sbin/:/usr/sbin/:/usr/bin/:/bin/',
  }

  # manage root password if it is set
  if $root_password != 'UNSET' {
    case $old_root_password {
      '':      { $old_pw='' }
      default: { $old_pw="-p'${old_root_password}'" }
    }

    exec { 'set_mysql_rootpw':
      command   => "mysqladmin -u root ${old_pw} password '${root_password}'",
      logoutput => true,
      unless    => "mysqladmin -u root -p'${root_password}' status > /dev/null",
      path      => '/usr/local/sbin:/usr/bin:/usr/local/bin',
      notify    => Exec['mysqld-restart'],
      require   => File['/etc/mysql/conf.d'],
    }

    file { '/root/.my.cnf':
      content => template('mysql/my.cnf.pass.erb'),
      require => Exec['set_mysql_rootpw'],
    }

    if $etc_root_password {
      file{ '/etc/my.cnf':
        content => template('mysql/my.cnf.pass.erb'),
        require => Exec['set_mysql_rootpw'],
      }
    }
  }

  file { '/etc/mysql':
    ensure => directory,
    mode   => '0755',
  }
  file { '/etc/mysql/conf.d':
    ensure => directory,
    mode   => '0755',
  }
  file { $config_file:
    content => template('mysql/my.cnf.erb'),
    mode    => '0644',
  }

}
