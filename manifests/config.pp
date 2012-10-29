# Class: mysql::config
#
# Parameters:
#
#   [*root_password*]     - root user password.
#   [*old_root_password*] - previous root user password,
#   [*bind_address*]      - address to bind service.
#   [*port*]              - port to bind service.
#   [*etc_root_password*] - whether to save /etc/my.cnf.
#   [*service_name*]      - mysql service name.
#   [*config_file*]       - my.cnf configuration file path.
#   [*socket*]            - mysql socket.
#   [*datadir*]           - path to datadir.
#   [*ssl]                - enable ssl
#   [*ssl_ca]             - path to ssl-ca
#   [*ssl_cert]           - path to ssl-cert
#   [*ssl_key]            - path to ssl-key
#   [*log_error]          - path to mysql error log
#   [*default_engine]     - configure a default table engine
#   [*root_group]         - use specified group for root-owned files
#   [*restart]            - whether to restart mysqld (true/false)
# 
#   Many other parameters each of which has a default in params.pp, and each represents a directive for my.cnf.
#   You can also use extra_configs => { key => value }
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
  $root_password     							= 'UNSET',
  $old_root_password 							= '',
  $bind_address      							= $mysql::params::bind_address,
  $port              							= $mysql::params::port,
  $etc_root_password 							= $mysql::params::etc_root_password,
  $service_name      							= $mysql::params::service_name,
  $config_file       							= $mysql::params::config_file,
  $socket            							= $mysql::params::socket,
  $pidfile           							= $mysql::params::pidfile,
  $datadir           							= $mysql::params::datadir,
  $ssl               							= $mysql::params::ssl,
  $ssl_ca            							= $mysql::params::ssl_ca,
  $ssl_cert          							= $mysql::params::ssl_cert,
  $ssl_key           							= $mysql::params::ssl_key,
  $log_error         				      = $mysql::params::log_error,
  $slow_query_log_file    				= $mysql::params::slow_query_log_file,
  $long_query_time        				= $mysql::params::long_query_time,
  $read_only              				= $mysql::params::read_only,
  $replication_enabled    				= $mysql::params::replication_enabled,
  $expire_logs_days       				= $mysql::params::expire_logs_days,
  $max_binlog_size        				= $mysql::params::max_binlog_size,
  $max_allowed_packet             = $mysql::params::max_allowed_packet,
  $auto_increment_increment				= $mysql::params::auto_increment_increment,
  $auto_increment_offset   				= '',
  $replicate_ignore_table 				= $mysql::params::replicate_ignore_table,
  $replicate_ignore_db    				= $mysql::params::replicate_ignore_db,
  $replicate_do_table     				= $mysql::params::replicate_do_table,
  $replicate_do_db        				= $mysql::params::replicate_do_db,
  $innodb_file_per_table          = $mysql::params::innodb_file_per_table,
  $innodb_flush_log_at_trx_commit = $mysql::params::innodb_flush_log_at_trx_commit,
  $innodb_buffer_pool_size        = $mysql::params::innodb_buffer_pool_size,
  $innodb_status_file             = $mysql::params::innodb_status_file,
  $innodb_support_xa              = $mysql::params::innodb_support_xa,
  $innodb_log_file_size           = $mysql::params::innodb_log_file_size,
  $innodb_flush_method            = $mysql::params::innodb_flush_method,
  $innodb_thread_concurrency      = $mysql::params::innodb_thread_concurrency,
  $innodb_concurrency_tickets     = $mysql::params::innodb_concurrency_tickets,
  $innodb_doublewrite             = $mysql::params::innodb_doublewrite,
  $ft_min_word_len                = $mysql::params::ft_min_word_len,
  $default_engine    							= 'UNSET',
  $root_group        							= $mysql::params::root_group,
  $restart           							= $mysql::params::restart,
  $extra_configs          				= $mysql::params::extra_configs
) inherits mysql::params {

  File {
    owner  => 'root',
    group  => $root_group,
    mode   => '0400',
    notify    => $restart ? {
      true => Exec['mysqld-restart'],
      false => undef,
    },
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
      notify    => $restart ? {
        true => Exec['mysqld-restart'],
        false => undef,
      },
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
  } else {
    file { '/root/.my.cnf':
      ensure  => present,
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
