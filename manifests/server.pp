# Class: mysql::server
#
# manages the installation of the mysql server.  manages the package, service,
# my.cnf
#
# Parameters:
#  [*config_hash*]      - hash of config parameters that need to be set.
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
  $config_hash      = {},
  $enabled          = true,
  $manage_service   = true,
  $package_ensure   = $mysql::package_ensure,
  $package_name     = $mysql::server_package_name,
  $service_name     = $mysql::service_name,
  $service_provider = $mysql::service_provider
) inherits mysql {

  Class['mysql::config::files'] -> Class['mysql::server'] -> Class['mysql::server::service'] -> Class['mysql::config']

  $config_files_class = { 'mysql::config::files' => $config_hash }
  $config_class = { 'mysql::config' => $config_hash }

  create_resources( 'class', $config_files_class )
  create_resources( 'class', $config_class )

  class { 'mysql::server::service': }

  package { 'mysql-server':
    ensure => $package_ensure,
    name   => $package_name,
  }

}
