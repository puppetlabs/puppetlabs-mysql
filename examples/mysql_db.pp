class { 'mysql::server':
  root_password => 'password',
}
mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
}
mysql::db { "mydb_${facts['networking']['fqdn']}":
  user     => 'myuser',
  password => 'mypass',
  dbname   => 'mydb',
  host     => $facts['networking']['fqdn'],
  grant    => ['SELECT', 'UPDATE'],
  tag      => $domain,
}
