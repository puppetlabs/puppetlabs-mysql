# Class: mysql
#
# this module installs mysql client software.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql {
  package {"mysql-client": ensure => installed }
}
