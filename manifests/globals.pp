# See README.md for more details.
class mysql::globals (
  $config_file        = $mysql::params::config_file,
  $manage_config_file = $mysql::params::manage_config_file,
  $old_root_password  = $mysql::params::old_root_password,
  $override_options   = {},
  $purge_conf_dir     = $mysql::params::purge_conf_dir,
  $restart            = $mysql::params::restart,
  $root_group         = $mysql::params::root_group,
) inherits mysql::params {

  case $::operatingsystem {
    'Ubuntu': {
      $service_provider = upstart
    }
    default: {
      $service_provider = undef
    }
  }

  $default_options = {
    'client'          => {
      'port'          => '3306',
      'socket'        => $mysql::params::socket,
    },
    'mysqld_safe'        => {
      'nice'             => '0',
      'log_error'        => $mysql::params::log_error,
      'socket'           => $mysql::params::socket,
    },
    'mysqld'                  => {
      'basedir'               => $mysql::params::basedir,
      'bind_address'          => '127.0.0.1',
      'datadir'               => $mysql::params::datadir,
      'expire_logs_days'      => '10',
      'key_buffer'            => '16M',
      'log_error'             => $mysql::params::log_error,
      'max_allowed_packet'    => '16M',
      'max_binlog_size'       => '100M',
      'max_connections'       => '151',
      'myisam_recover'        => 'BACKUP',
      'pid_file'              => $mysql::params::pidfile,
      'port'                  => '3306',
      'query_cache_limit'     => '1M',
      'query_cache_size'      => '16M',
      'skip-external-locking' => true,
      'socket'                => $mysql::params::socket,
      'ssl'                   => false,
      'ssl-ca'                => $mysql::params::ssl_ca,
      'ssl-cert'              => $mysql::params::ssl_cert,
      'ssl-key'               => $mysql::params::ssl_key,
      'thread_cache_size'     => '8',
      'thread_stack'          => '256K',
      'tmpdir'                => $mysql::params::tmpdir,
      'user'                  => 'mysql',
    },
    'mysqldump'             => {
      'max_allowed_packets' => '16M',
      'quick'               => true,
      'quote-names'         => true,
    },
    'isamchk'      => {
      'key_buffer' => '16M',
    },
  }

# Create a merged together set of options.  Rightmost hashes win over left.
$options = merge($default_options, $override_options)

}
