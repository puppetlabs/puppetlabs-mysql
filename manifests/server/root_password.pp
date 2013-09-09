#
class mysql::server::root_password {

  $options = $mysql::globals::options
  $service_restart = $options['restart'] ? {
    true  => Exec['mysqld-restart'],
    false => undef,
  }

  # This kind of sucks, that I have to specify a difference resource for
  # restart.  the reason is that I need the service to be started before mods
  # to the config file which can cause a refresh
  exec { 'mysqld-restart':
    command     => "service ${options['service_name']} restart",
    logoutput   => on_failure,
    refreshonly => true,
    path        => '/sbin/:/usr/sbin/:/usr/bin/:/bin/',
  }

  # manage root password if it is set
  if $options['root_password'] != 'UNSET' {
    case $options['old_root_password'] {
      '':      { $old_pw='' }
      default: { $old_pw="-p'${options[old_root_password]}'" }
    }

    exec { 'set_mysql_rootpw':
      command     => "mysqladmin -u root ${old_pw} password '${options[root_password]}'",
      logoutput   => true,
      environment => "HOME=${::root_home}",
      unless      => "mysqladmin -u root -p'${options[root_password]}' status > /dev/null",
      path        => '/usr/local/sbin:/usr/bin:/usr/local/bin',
      notify      => $service_restart,
      require     => File['/etc/mysql/conf.d'],
    }

    file { "${::root_home}/.my.cnf":
      content => template('mysql/my.cnf.pass.erb'),
      require => Exec['set_mysql_rootpw'],
      notify  => undef,
    }

    if $options['etc_root_password'] {
      file{ '/etc/my.cnf':
        content => template('mysql/my.cnf.pass.erb'),
        require => Exec['set_mysql_rootpw'],
      }
    }
  } else {
    file { "${::root_home}/.my.cnf":
      ensure  => present,
    }
  }

}
