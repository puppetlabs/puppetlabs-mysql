class { 'mysql::server':
  config_hash =>  {
      'root_password' => 'password',
      #'old_root_password' => 'puppet'
    }
}
