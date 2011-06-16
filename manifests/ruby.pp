# Class: mysql::ruby
#
# installs the ruby bindings for mysql
#
# Parameters:
#   [*ensure*]       - ensure state for package.
#                        can be specified as version.
#   [*package_name*] - name of package
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::ruby(
  $ensure = installed,
  $package_name = $mysql::params::ruby_package_name,
  $package_provider = 'gem'
) inherits mysql::params {
  # I am not making the mysql package a dep for this
  # the only dep is the package which yum will resolve for me.
  #case $operatingsystem {
  #  'debian', 'ubuntu' : {$ruby_mysql_name = 'libmysql-ruby'}
  #  default: {$ruby_mysql_name = 'ruby-mysql'}
  #}

  package{'ruby-mysql':
  #  name => $ruby_mysql_name,
    name => $package_name, 
    provider => $package_provider,
    ensure   => $ensure,
  }
}
