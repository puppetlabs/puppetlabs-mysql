class { 'mysql::server':
  root_password => 'password'
}

mysql::plugin{ 'validate_password':
  ensure => present,
  soname => $::osfamily ? {
    windows => 'validate_password.dll',
    default => 'validate_password.so'
  }
}

mysql::plugin{ 'auth_socket':
  ensure => present,
  soname => $::osfamily ? {
    windows => 'auth_socket.dll',
    default => 'auth_socket.so'
  }
}
