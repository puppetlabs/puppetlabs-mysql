# Class: mysql::server
#
# manages the installation of the mysql server.  manages the package, service,
# my.cnf
#
# Parameters:
#  [*enabled*]          - Defaults to true, boolean to set service ensure.
#  [*manage_service*]   - Boolean dictating if mysql::server should manage the service
#  [*package_ensure*]   - Ensure state for package. Can be specified as version.
#  [*package_name*]     - The name of package
#  [*service_name*]     - The name of service
#  [*service_provider*] - What service provider to use.

#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::server (
  $enabled          = true,
  $manage_service   = true,
  $package_ensure   = $mysql::globals::package_ensure,
  $package_name     = $mysql::globals::server_package_name,
  $service_name     = $mysql::globals::service_name,
  $service_provider = $mysql::globals::service_provider
) inherits mysql::globals {

  Class['mysql::server::root_password'] -> Mysql::Db <| |>

  include '::mysql::server::install'
  include '::mysql::server::config'
  include '::mysql::server::service'
  include '::mysql::server::root_password'

  Class['mysql::server::install'] ->
  Class['mysql::server::config'] ->
  Class['mysql::server::service'] ->
  Class['mysql::server::root_password']

}
