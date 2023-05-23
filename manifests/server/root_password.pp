# @summary
#   Private class for managing the root password
#
# @api private
#
class mysql::server::root_password {
  if $mysql::server::root_password =~ Sensitive {
    $root_password = $mysql::server::root_password.unwrap
  } else {
    $root_password = $mysql::server::root_password
  }
  if $root_password == 'UNSET' {
    $root_password_set = false
  } else {
    $root_password_set = true
  }

  $options = $mysql::server::_options
  $login_file = $mysql::server::login_file

  # New installations of MySQL will configure a default random password for the root user
  # with an expiration. No actions can be performed until this password is changed. The
  # below exec will remove this default password. If the user has supplied a root
  # password it will be set further down with the mysql_user resource.
  exec { 'remove install pass':
    command => "mysqladmin -u root --password=\$(grep -o '[^ ]\\+\$' /.mysql_secret) password && (rm -f  /.mysql_secret; exit 0) || (rm -f /.mysql_secret; exit 1)",
    onlyif  => [['test', '-f' ,'/.mysql_secret']],
    path    => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
  }

  # manage root password if it is set
  if $mysql::server::create_root_user and $root_password_set {
    mysql_user { 'root@localhost':
      ensure        => present,
      password_hash => Deferred('mysql::password', [$mysql::server::root_password]),
      require       => Exec['remove install pass'],
    }
  }

  if $mysql::server::create_root_my_cnf and $root_password_set {
    # TODO: use EPP instead of ERB, as EPP can handle Data of Type Sensitive without further ado
    file { "${facts['root_home']}/.my.cnf":
      content => template('mysql/my.cnf.pass.erb'),
      owner   => 'root',
      mode    => '0600',
    }

    # show_diff was added with puppet 3.0
    if versioncmp($facts['puppetversion'], '3.0') >= 0 {
      File["${facts['root_home']}/.my.cnf"] { show_diff => false }
    }
    if $mysql::server::create_root_user {
      Mysql_user['root@localhost'] -> File["${facts['root_home']}/.my.cnf"]
    }
  }

  if $mysql::server::create_root_login_file and $root_password_set {
    file { "${facts['root_home']}/.mylogin.cnf":
      source => $login_file,
      owner  => 'root',
      mode   => '0600',
    }
  }
}
