class { 'mysql::server':
  root_password => 'password',
}
mysql_database { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
}
mysql_database { "mydb_${fqdn}":
  user     => 'myuser',
  password => 'mypass',
  dbname   => 'mydb',
  host     => $::fqdn,
  grant    => ['SELECT', 'UPDATE'],
  tag      => $domain,
}
