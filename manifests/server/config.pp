# See README.me for options.
class mysql::server::config {

  File {
    owner  => 'root',
    group  => $mysql::globals::root_group,
    mode   => '0400',
    notify => Class['mysql::server::service'],
  }

  file { '/etc/mysql':
    ensure => directory,
    mode   => '0755',
  }

  file { '/etc/mysql/conf.d':
    ensure  => directory,
    mode    => '0755',
    recurse => $mysql::globals::purge_conf_dir,
    purge   => $mysql::globals::purge_conf_dir,
  }

  if $mysql::globals::manage_config_file  {
    file { $mysql::globals::config_file:
      content => template('mysql/my.cnf.erb'),
      mode    => '0644',
    }
  }
}
