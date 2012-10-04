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
class mysql (
  $package_ensure = 'present',
  $software_package = 'distro'
) inherits mysql::params {
}
