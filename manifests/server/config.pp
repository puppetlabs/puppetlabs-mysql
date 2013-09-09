# See README.me for options.
class mysql::server::config {

  $options = $mysql::globals::options

  File {
    owner  => 'root',
    group  => $options['root_group'],
    mode   => '0400',
    notify => Class['mysql::server::service'],
  }

  if ( $options['ssl'] ) and ( $options['ssl_ca'] == undef ) {
    fail('The ssl_ca parameter is required when ssl is true')
  }

  if ( $options['ssl'] ) and ( $options['ssl_cert'] == undef ) {
    fail('The ssl_cert parameter is required when ssl is true')
  }

  if ( $options['ssl'] ) and ( $options['ssl_key'] ) == undef {
    fail('The ssl_key parameter is required when ssl is true')
  }

  file { '/etc/mysql':
    ensure => directory,
    mode   => '0755',
  }

  file { '/etc/mysql/conf.d':
    ensure  => directory,
    mode    => '0755',
    recurse => $options['purge_conf_dir'],
    purge   => $options['purge_conf_dir'],
  }

  if $options['manage_config_file']  {
    file { $options['config_file']:
      content => template('mysql/my.cnf.erb'),
      mode    => '0644',
    }
  }
}
