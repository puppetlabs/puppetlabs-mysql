#
class mysql::client (
  $bindings_enable = $mysql::params::bindings_enable,
  $install_options = undef,
  $package_ensure  = $mysql::params::client_package_ensure,
  $package_manage  = $mysql::params::client_package_manage,
  $package_name    = $mysql::params::client_package_name,
) inherits mysql::params {

  include '::mysql::client::install'

  if $bindings_enable {
    class { 'mysql::bindings':
      java_enable   => true,
      perl_enable   => true,
      php_enable    => true,
      python_enable => true,
      ruby_enable   => true,
    }
  }


  # Anchor pattern workaround to avoid resources of mysql::client::install to
  # "float off" outside mysql::client
  # JOE
  # Did this to avoid:
  # Error: Could not apply complete catalog: Found 1 dependency cycle:
  # (Anchor[mysql::client::end] => Class[Mysql::Client] => Anchor[mysql::db_quartz::end] => Mysql::Db[quartz] => Mysql::Db[repository] => Anchor[mysql::db_repository::begin] => Class[Mysql::Client] => Anchor[mysql::client::end])
  anchor { 'mysql::client::start': } ->
  #  Class['mysql::client::install'] ->
  anchor { 'mysql::client::end': }

}
