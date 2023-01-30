# @summary
#   "Provider" for mysqldump
# @api private
#
class mysql::backup::mysqldump (
  String                                        $backupuser               = '',
  Variant[String, Sensitive[String]]            $backuppassword           = '',
  String                                        $backupdir                = '',
  String[1]                                     $maxallowedpacket         = '1M',
  String[1]                                     $backupdirmode            = '0700',
  String[1]                                     $backupdirowner           = 'root',
  String[1]                                     $backupdirgroup           = $mysql::params::root_group,
  Boolean                                       $backupcompress           = true,
  Variant[Integer, String[1]]                   $backuprotate             = 30,
  String[1]                                     $backupmethod             = 'mysqldump',
  Optional[String[1]]                           $backup_success_file_path = undef,
  Boolean                                       $ignore_events            = true,
  Boolean                                       $delete_before_dump       = false,
  Array[String[1]]                              $backupdatabases          = [],
  Boolean                                       $file_per_database        = false,
  Boolean                                       $include_triggers         = false,
  Boolean                                       $include_routines         = false,
  Enum['present', 'absent']                     $ensure                   = 'present',
  Variant[Array[String[1]], Array[Integer]]     $time                     = ['23', '5'],
  Variant[Boolean, String[1], Array[String[1]]] $prescript                = false,
  Variant[Boolean, String[1], Array[String[1]]] $postscript               = false,
  String[1]                                     $execpath                 = '/usr/bin:/usr/sbin:/bin:/sbin',
  Array[String[1]]                              $optional_args            = [],
  String[1]                                     $mysqlbackupdir_ensure    = 'directory',
  Optional[String[1]]                           $mysqlbackupdir_target    = undef,
  Boolean                                       $incremental_backups      = false,
  Boolean                                       $install_cron             = true,
  String[1]                                     $compression_command      = 'bzcat -zc',
  String[1]                                     $compression_extension    = '.bz2',
  Optional[String[1]]                           $backupmethod_package     = undef,
  Array[String]                                 $excludedatabases         = [],
) inherits mysql::params {
  $backuppassword_unsensitive = if $backuppassword =~ Sensitive {
    $backuppassword.unwrap
  } else {
    $backuppassword
  }

  unless $facts['os']['family'] == 'FreeBSD' {
    if $backupcompress and $compression_command == 'bzcat -zc' {
      ensure_packages(['bzip2'])
      Package['bzip2'] -> File['mysqlbackup.sh']
    }
  }

  mysql_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => mysql::password($backuppassword),
    require       => Class['mysql::server::root_password'],
  }

  if $include_triggers {
    $privs = ['SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'PROCESS', 'TRIGGER']
  } else {
    $privs = ['SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'PROCESS']
  }

  mysql_grant { "${backupuser}@localhost/*.*":
    ensure     => $ensure,
    user       => "${backupuser}@localhost",
    table      => '*.*',
    privileges => $privs,
    require    => Mysql_user["${backupuser}@localhost"],
  }

  if $install_cron {
    if $facts['os']['family'] == 'RedHat' {
      ensure_packages('cronie')
    } elsif $facts['os']['family'] != 'FreeBSD' {
      ensure_packages('cron')
    }
  }

  cron { 'mysql-backup':
    ensure   => $ensure,
    command  => '/usr/local/sbin/mysqlbackup.sh',
    user     => 'root',
    hour     => $time[0],
    minute   => $time[1],
    monthday => $time[2],
    month    => $time[3],
    weekday  => $time[4],
    require  => File['mysqlbackup.sh'],
  }

  # TODO: use EPP instead of ERB, as EPP can handle Data of Type Sensitive without further ado
  file { 'mysqlbackup.sh':
    ensure  => $ensure,
    path    => '/usr/local/sbin/mysqlbackup.sh',
    mode    => '0700',
    owner   => 'root',
    group   => $mysql::params::root_group,
    content => template('mysql/mysqlbackup.sh.erb'),
  }

  if $mysqlbackupdir_target {
    file { $backupdir:
      ensure => $mysqlbackupdir_ensure,
      target => $mysqlbackupdir_target,
      mode   => $backupdirmode,
      owner  => $backupdirowner,
      group  => $backupdirgroup,
    }
  } else {
    file { $backupdir:
      ensure => $mysqlbackupdir_ensure,
      mode   => $backupdirmode,
      owner  => $backupdirowner,
      group  => $backupdirgroup,
    }
  }
}
