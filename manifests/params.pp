class mysql::params{
  $socket = '/var/run/mysqld/mysqld.sock'
  case $operatingsystem {
    'centos', 'redhat', 'fedora': {
      $service_name = 'mysqld'
    }
    'ubuntu', 'debian': {
      $service_name = 'mysql'
    }
    default: {
      $python_package_name = 'python-mysqldb'
      $ruby_package_name = 'ruby-mysql'
    }
  }
}
