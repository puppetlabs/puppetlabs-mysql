# Class: mysql
#
#   This class installs mysql client software.
#
# Parameters:
#
# [*basedir*]               - The base directory mysql uses
#
# [*bind_address*]          - The IP mysql binds to.
#
# [*client_package_name*]   - The name of the mysql client package.
#
# [*client_package_ensure*] - State of the client package.
#
# [*config_file*]           - The location of the server config file
#
# [*config_template*]       - The template to use to generate my.cnf.
#
# [*datadir*]               - The directory MySQL's datafiles are stored
#
# [*tmpdir*]                - The directory MySQL's tmpfiles are stored
#
# [*default_engine*]        - The default engine to use for tables
#
# [*etc_root_password*]     - Whether or not to add the mysql root password to /etc/my.cnf
#
# [*log_error*]             - Where to log errors
#
# [*manage_config_file*]    - if the config file should be managed (default: true)
#
# [*manage_service*]        - Boolean dictating if mysql::server should manage the service
#
# [*max_allowed_packet*]    - Maximum network packet size mysqld will accept
#
# [*old_root_password*]     - Previous root user password,
#
# [*package_ensure*]        - ensure value for packages.
#
# [*package_name*]          - legacy parameter used to specify the client package. Should not be used going forward
#
# [*php_package_name*]      - The name of the phpmysql package to install
#
# [*pidfile*]               - The location mysql will expect the pidfile to be, and will put it when starting the service.
#
# [*port*]                  - The port mysql listens on
#
# [*purge_conf_dir*]        - Value fed to recurse and purge parameters of the /etc/mysql/conf.d resource
#
# [*restart*]               - Whether to restart mysqld (true/false)
#
# [*root_group*]            - Use specified group for root-owned files
#
# [*root_password*]         - The root MySQL password to use
#
# [*server_package_ensure*] - ensure value for server packages.
#
# [*server_package_name*]   - The name of the server package to install
#
# [*service_provider*]      - Sets the service provider to upstart on Ubuntu systems for mysql::server.
#
# [*service_name*]          - The name of the service to start
#
# [*socket*]                - The location of the MySQL server socket file
#
# [*ssl*]                   - Whether or not to enable ssl
#
# [*ssl_ca*]                - The location of the SSL CA Cert
#
# [*ssl_cert*]              - The location of the SSL Certificate to use
#
# [*ssl_key*]               - The SSL key to use
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql(
  $basedir               = $mysql::params::basedir,
  $bind_address          = $mysql::params::bind_address,
  $client_package_name   = $mysql::params::client_package_name,
  $client_package_ensure = $mysql::params::client_package_ensure,
  $config_file           = $mysql::params::config_file,
  $config_template       = $mysql::params::config_template,
  $datadir               = $mysql::params::datadir,
  $tmpdir                = $mysql::params::tmpdir,
  $default_engine        = $mysql::params::default_engine,
  $etc_root_password     = $mysql::params::etc_root_password,
  $log_error             = $mysql::params::log_error,
  $manage_config_file    = true,
  $manage_service        = $mysql::params::manage_service,
  $max_allowed_packet    = $mysql::params::max_allowed_packet,
  $old_root_password     = $mysql::params::old_root_password,
  $package_ensure        = $mysql::params::package_ensure,
  $php_package_name      = $mysql::params::php_package_name,
  $pidfile               = $mysql::params::pidfile,
  $port                  = $mysql::params::port,
  $purge_conf_dir        = $mysql::params::purge_conf_dir,
  $max_connections       = $mysql::params::max_connections,
  $restart               = $mysql::params::restart,
  $root_group            = $mysql::params::root_group,
  $root_password         = $mysql::params::root_password,
  $server_package_name   = $mysql::params::server_package_name,
  $service_name          = $mysql::params::service_name,
  $service_provider      = $mysql::params::service_provider,
  $socket                = $mysql::params::socket,
  $ssl                   = $mysql::params::ssl,
  $ssl_ca                = $mysql::params::ssl_ca,
  $ssl_cert              = $mysql::params::ssl_cert,
  $ssl_key               = $mysql::params::ssl_key
) inherits mysql::params{

  include '::mysql::client::install'
  include '::mysql::bindings'

  Class['mysql::config'] -> Mysql::Db <| |>

}
