class { 'mysql::server':
  root_password => 'password',
}

$validate_password_soname = $facts['os']['family'] ? {
  'windows' => 'validate_password.dll',
  default => 'validate_password.so'
}

mysql_plugin { 'validate_password':
  ensure => present,
  soname => $validate_password_soname,
}

$auth_socket_soname = $facts['os']['family'] ? {
  'windows' => 'auth_socket.dll',
  default => 'auth_socket.so'
}

mysql_plugin { 'auth_socket':
  ensure => present,
  soname => $auth_socket_soname,
}
