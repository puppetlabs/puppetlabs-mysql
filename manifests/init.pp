# Class: mysql
#
#   This class installs mysql client software.
#
# Parameters:
#   [*client_package_name*]  - The name of the mysql client package.
#   [*software_package*]  - to allow alternative packages; specify "distro" for distro defaults, "ius" to use mysql55 packages on RedHat familiy (from iuscommunity.org) 
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#  class { 'mysql':
#    software_package => 'ius',
#  }
#  class { 'mysql::server':
#    config_hash => { 
#      'root_password' => 'badsecret',
#      'innodb_flush_method' => 'O_DIRECT',
#      'max_allowed_packet'  => '1024M',
#      'innodb_buffer_pool_size' => '128M',
#      'auto_increment_increment'   => '4',
#      'replication_enabled'     => 'true',
#      'auto_increment_offset'   => '1',
#      'extra_configs' => { 'foo' => 'bar' },
#    }
#  }
class mysql (
  $package_ensure = 'present',
  $software_package = 'distro'
) inherits mysql::params {

  include mysql::client
}
