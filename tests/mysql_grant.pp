database_grant {'test1@localhost/redmine':
  privileges => [update, create, drop],
  ensure     => absent,
}


database_user {'test1@localhost':
  ensure        => present,
  password_hash => mysql_password('password'),
}
