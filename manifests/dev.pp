# Class: mysql::dev
#
# installs mysql development libraries
#
# For all parameters, the value given will be passed to each package as the
# ensure statement, i.e. present, absent or a version string are vaild
#
# Parameters:
#   [*mysqlclient*] installs the mysqlclient-dev libraries
#
# Actions:
#
# Requires:
#
# Sample Usage:
# class { 'mysql::dev': mysqlclient => present}
class mysql::dev(
  $mysqlclient = undef,
) inherits mysql::params {

# This structure might seem contrived, but for each package and OS
# all that's required is an appropriate package name to be set up
# in mysql::params
  if $mysqlclient {
    if $mysql::params::myslqclient_dev_package {
      package {$mysql::params::myslqclient_dev_package:
        ensure => $mysqlclient,
      }
    } else {
      warning ("The mysqlclient development library not configured for ${::osfamily} on ${::fqdn}")
    }
  }

}