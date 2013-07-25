# Class: mysql::bindings
#
#   This class installs various bindings for mysql.
#
# Parameters:
#
# [*java_enable*]           - Boolean to determine if we should include the java bindings.
#
# [*perl_enable*]           - Boolean to determine if we should include the perl bindings.
#
# [*python_enable*]         - Boolean to determine if we should include the python bindings.
#
# [*ruby_enable*]           - Boolean to determine if we should include the ruby bindings.
#
# [*java_package_name*]     - The name of the java package containing the java connector
#
# [*java_package_ensure*]   - State of the java binding packages.
#
# [*perl_package_ensure*]   - State of the perl binding packages.
#
# [*perl_package_name*]     - The name of the perl mysql package to install
#
# [*perl_package_provider*] - The provider to use when installing the perl package.
#
# [*python_package_ensure*] - State of the python binding packages.
#
# [*python_package_name*]   - The name of the python mysql package to install
#
# [*ruby_ensure*]           - State of the ruby binding packages.
#
# [*ruby_package_name*]     - The name of the ruby mysql package to install
#
# [*ruby_package_provider*] - The provider to use when installing the ruby package.
#
class mysql::bindings (
  # Boolean to determine if we should include the classes.
  $java_enable   = false,
  $perl_enable   = false,
  $python_enable = false,
  $ruby_enable   = false,
  # Settings for the various classes.
  $java_package_ensure   = $mysql::params::java_package_ensure,
  $java_package_name     = $mysql::params::java_package_name,
  $perl_package_ensure   = $mysql::params::perl_package_ensure,
  $perl_package_name     = $mysql::params::perl_package_name,
  $perl_package_provider = $mysql::params::perl_package_provider,
  $python_package_ensure = $mysql::params::python_package_ensure,
  $python_package_name   = $mysql::params::python_package_name,
  $ruby_package_ensure   = $mysql::params::ruby_package_ensure,
  $ruby_package_name     = $mysql::params::ruby_package_name,
  $ruby_package_provider = $mysql::params::ruby_package_provider
) inherits mysql::params {

  if $java_enable   { include '::mysql::bindings::java' }
  if $perl_enable   { include '::mysql::bindings::perl' }
  if $python_enable { include '::mysql::bindings::python' }
  if $ruby_enable   { include '::mysql::bindings::ruby' }

}
