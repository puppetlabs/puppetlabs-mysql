# @summary
#   Installs and configures the MySQL server.
#
# @example Install MySQL Server
#   class { '::mysql::server':
#     package_name            => 'mysql-server',
#     package_ensure          => '5.7.1+mysql~trusty',
#     root_password           => 'strongpassword',
#     remove_default_accounts => true,
#   }
#
# @param config_file
#   The location, as a path, of the MySQL configuration file.
# @param config_file_mode
#   The MySQL configuration file's permissions mode.
# @param includedir
#   The location, as a path, of !includedir for custom configuration overrides.
# @param install_options
#   Passes [install_options](https://docs.puppetlabs.com/references/latest/type.html#package-attribute-install_options) array to managed package resources. You must pass the appropriate options for the specified package manager
# @param manage_config_file
#   Whether the MySQL configuration file should be managed. Valid values are `true`, `false`. Defaults to `true`.
# @param options
#   A hash of options structured like the override_options, but not merged with the default options. 
#   Use this if you don't want your options merged with the default options.
# @param override_options
#   Specifies override options to pass into MySQL. Structured like a hash in the my.cnf file:  See  above for usage details.
# @param package_ensure
#   Whether the package exists or should be a specific version. Valid values are 'present', 'absent', or 'x.y.z'. Defaults to 'present'.
# @param package_manage
#   Whether to manage the MySQL server package. Defaults to `true`.
# @param package_name
#   The name of the MySQL server package to install.
# @param package_provider
#   Define a specific provider for package install.
# @param package_source
#   The location of the package source (require for some package provider)
# @param purge_conf_dir
#   Whether the `includedir` directory should be purged. Valid values are `true`, `false`. Defaults to `false`.
# @param remove_default_accounts
#   Specifies whether to automatically include `mysql::server::account_security`. Valid values are `true`, `false`. Defaults to `false`.
# @param restart
#   Whether the service should be restarted when things change. Valid values are `true`, `false`. Defaults to `false`.
# @param root_group
#   The name of the group used for root. Can be a group name or a group ID. See more about the [group](https://docs.puppetlabs.com/references/latest/type.html#file-attribute-group).
# @param managed_dirs
#   An array containing all directories to be managed.
# @param mysql_group
#   The name of the group of the MySQL daemon user. Can be a group name or a group ID. See more about the [group](https://docs.puppetlabs.com/references/latest/type.html#file-attribute-group).
# @param mycnf_owner
#   Name or user-id who owns the mysql-config-file.
# @param mycnf_group
#   Name or group-id which owns the mysql-config-file.
# @param root_password
#   The MySQL root password. Puppet attempts to set the root password and update `/root/.my.cnf` with it. This is required 
#   if `create_root_user` or `create_root_my_cnf` are true. If `root_password` is 'UNSET', then `create_root_user` and 
#   `create_root_my_cnf` are assumed to be false --- that is, the MySQL root user and `/root/.my.cnf` are not created. 
#   Password changes are supported; however, the old password must be set in `/root/.my.cnf`. Effectively, Puppet uses the old 
#   password, configured in `/root/my.cnf`, to set the new password in MySQL, and then updates `/root/.my.cnf` with the new password.
# @param service_enabled
#   Specifies whether the service should be enabled. Valid values are `true`, `false`. Defaults to `true`.
# @param service_manage
#   Specifies whether the service should be managed. Valid values are `true`, `false`. Defaults to `true`.
# @param service_name
#   The name of the MySQL server service. Defaults are OS dependent, defined in 'params.pp'.
# @param service_provider
#   The provider to use to manage the service. For Ubuntu, defaults to 'upstart'; otherwise, default is undefined.
# @param create_root_user
#   Whether root user should be created. Valid values are `true`, `false`. Defaults to `true`. 
#   This is useful for a cluster setup with Galera. The root user has to be created only once. 
#   You can set this parameter true on one node and set it to false on the remaining nodes.
# @param create_root_my_cnf
#   Whether to create `/root/.my.cnf`. Valid values are `true`, `false`. Defaults to `true`. 
#   `create_root_my_cnf` allows creation of `/root/.my.cnf` independently of `create_root_user`. 
#   You can use this for a cluster setup with Galera where you want `/root/.my.cnf` to exist on all nodes.
# @param create_root_login_file
#   Whether to create a login file for root. Valid values are 'true', 'false'.
# @param login_file
#   Specify the login file.
# @param users
#   Optional hash of users to create, which are passed to [mysql_user](#mysql_user).
# @param grants
#   Optional hash of grants, which are passed to [mysql_grant](#mysql_grant).
# @param databases
#   Optional hash of databases to create, which are passed to [mysql_database](#mysql_database).
# @param reload_on_config_change
#   By default, a my.cnf change won't reload/restart the database. Turn this flag to true to enable it
# @param enabled
#   _Deprecated_
# @param manage_service
#   _Deprecated_
# @param old_root_password
#   This parameter no longer does anything. It exists only for backwards compatibility. 
#   See the `root_password` parameter above for details on changing the root password.
#
class mysql::server (
  String[1]                                                             $config_file             = $mysql::params::config_file,
  String[1]                                                             $config_file_mode        = '0644',
  Optional[String]                                                      $includedir              = $mysql::params::includedir,
  Optional[Array[String[1]]]                                            $install_options         = undef,
  Variant[Boolean, String[1]]                                           $manage_config_file      = true,
  Mysql::Options                                                        $options                 = {},
  Hash                                                                  $override_options        = {},
  Variant[Enum['present','absent'], Pattern[/(\d+)[\.](\d+)[\.](\d+)/]] $package_ensure          = 'present',
  Boolean                                                               $package_manage          = true,
  String[1]                                                             $package_name            = $mysql::params::server_package_name,
  Optional[String[1]]                                                   $package_provider        = undef,
  Optional[String[1]]                                                   $package_source          = undef,
  Variant[Boolean, String[1]]                                           $purge_conf_dir          = false,
  Variant[Boolean, String[1]]                                           $remove_default_accounts = false,
  Variant[Boolean, String[1]]                                           $restart                 = false,
  String[1]                                                             $root_group              = $mysql::params::root_group,
  Optional[Array[String[1]]]                                            $managed_dirs            = $mysql::params::managed_dirs,
  String[1]                                                             $mysql_group             = $mysql::params::mysql_group,
  Optional[String[1]]                                                   $mycnf_owner             = undef,
  Optional[String[1]]                                                   $mycnf_group             = undef,
  Variant[String, Sensitive[String]]                                    $root_password           = 'UNSET',
  Variant[Boolean, String[1]]                                           $service_enabled         = true,
  Variant[Boolean, String[1]]                                           $service_manage          = true,
  String[1]                                                             $service_name            = $mysql::params::server_service_name,
  Optional[String[1]]                                                   $service_provider        = $mysql::params::server_service_provider,
  Boolean                                                               $create_root_user        = true,
  Boolean                                                               $create_root_my_cnf      = true,
  Boolean                                                               $create_root_login_file  = false,
  Optional[String[1]]                                                   $login_file              = undef,
  Hash                                                                  $users                   = {},
  Hash                                                                  $grants                  = {},
  Hash                                                                  $databases               = {},
  Boolean                                                               $reload_on_config_change = false,
  # Deprecated parameters
  Optional[Variant[String[1], Boolean]]        $enabled                 = undef,
  Optional[Variant[String[1], Boolean]]        $manage_service          = undef,
  Optional[Variant[String, Sensitive[String]]] $old_root_password       = undef
) inherits mysql::params {
  # Deprecated parameters.
  if $enabled {
    crit('This parameter has been renamed to service_enabled.')
    $real_service_enabled = $enabled
  } else {
    $real_service_enabled = $service_enabled
  }
  if $manage_service {
    crit('This parameter has been renamed to service_manage.')
    $real_service_manage = $manage_service
  } else {
    $real_service_manage = $service_manage
  }
  if $old_root_password {
    warning('The `old_root_password` attribute is no longer used and will be removed in a future release.')
  }

  if ! empty($options) and ! empty($override_options) {
    fail('You can\'t specify $options and $override_options simultaneously, see the README section \'Customize server options\'!')
  }

  # If override_options are set, create a merged together set of options. Rightmost hashes win over left.
  # If options are set, just use them.
  $_options = empty($options) ? {
    true  => mysql::normalise_and_deepmerge($mysql::params::default_options, $override_options),
    false => $options,
  }

  Class['mysql::server::root_password'] -> Mysql::Db <| |>

  include 'mysql::server::config'
  include 'mysql::server::install'
  include 'mysql::server::managed_dirs'
  include 'mysql::server::installdb'
  include 'mysql::server::service'
  include 'mysql::server::root_password'
  include 'mysql::server::providers'

  if $remove_default_accounts {
    class { 'mysql::server::account_security':
      require => Anchor['mysql::server::end'],
    }
  }

  anchor { 'mysql::server::start': }
  anchor { 'mysql::server::end': }

  if $restart {
    Class['mysql::server::config']
    ~> Class['mysql::server::service']
  }

  if $_options['mysqld']['ssl-disable'] {
    notify { 'ssl-disable':
      message => 'Disabling SSL is evil! You should never ever do this except
                if you are forced to use a mysql version compiled without SSL support',
    }
  }

  Anchor['mysql::server::start']
  -> Class['mysql::server::config']
  -> Class['mysql::server::install']
  -> Class['mysql::server::managed_dirs']
  -> Class['mysql::server::installdb']
  -> Class['mysql::server::service']
  -> Class['mysql::server::root_password']
  -> Class['mysql::server::providers']
  -> Anchor['mysql::server::end']
}
