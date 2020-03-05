# Debian MySQL Commiunity Server 8.0
include apt
apt::source { 'repo.mysql.com':
  location => 'http://repo.mysql.com/apt/debian',
  release  => $::lsbdistcodename,
  repos    => 'mysql-8.0',
  key      => {
    id     => 'A4A9406876FCBD3C456770C88C718D3B5072E1F5',
    server => 'hkp://keyserver.ubuntu.com:80',
  },
  include  => {
    src => false,
    deb => true,
  },
  notify   => Exec['apt-get update']
}
exec { 'apt-get update':
  path        => '/usr/bin:/usr/sbin:/bin:/sbin',
  refreshonly => true,
}

$root_pw = 'password'
class { '::mysql::server':
  root_password      => $root_pw,
  service_name       => 'mysql',
  package_name       => 'mysql-community-server',
  create_root_my_cnf => false,
  require            => [
    Apt::Source['repo.mysql.com'],
    Exec['apt-get update']
  ],
  notify             => Mysql_login_path['client']
}

class { '::mysql::client':
  package_manage => false,
  package_name   => 'mysql-community-client',
  require        => Class['::mysql::server'],
}

mysql_login_path { 'client':
  ensure   => present,
  host     => 'localhost',
  user     => 'root',
  password => Sensitive($root_pw),
  socket   => '/var/run/mysqld/mysqld.sock',
  owner    => root,
}

mysql_login_path { 'local_dan':
  ensure   => present,
  host     => '127.0.0.1',
  user     => 'dan',
  password => Sensitive('blah'),
  port     => 3306,
  owner    => root,
  require  => Class['::mysql::server'],
}

mysql_user { 'dan@localhost':
  ensure        => present,
  password_hash => mysql::password('blah'),
  require       => Mysql_login_path['client'],
}




