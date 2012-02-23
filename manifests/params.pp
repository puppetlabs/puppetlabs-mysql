# Class: mysql::params
#
# This class holds parameters that need to be 
# accessed by other classes.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::params{
  case $::operatingsystem {
    'centos', 'redhat', 'fedora': {
      $service_name         = 'mysqld'
      $client_package_name  = 'mysql'
      $socket               = '/var/lib/mysql/mysql.sock'
      $config_file          = '/etc/my.cnf'
      $ruby_package_name    = 'ruby-mysql'
      $python_package_name  = 'MySQL-python'
    }
    'ubuntu', 'debian': {
      $service_name         = 'mysql'
      $client_package_name  = 'mysql-client'
      $socket               = '/var/run/mysqld/mysqld.sock'
      $config_file          = '/etc/mysql/my.cnf'
      $ruby_package_name    = 'libmysql-ruby'
      $python_package_name  = 'python-mysqldb'
    }
    default: {
      fail("Unsupported operating system: ${::operatingsystem}. ${module_name} supports debian, ubuntu, redhat, centos, and fedora.")
    }
  }
}
