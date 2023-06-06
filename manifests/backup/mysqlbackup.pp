# @summary
#   Manage the mysqlbackup client.
#
# @api private
#
class mysql::backup::mysqlbackup (
  String                                        $backupuser               = '',
  Variant[String, Sensitive[String]]            $backuppassword           = '',
  String[1]                                     $maxallowedpacket         = '1M',
  String                                        $backupdir                = '',
  String[1]                                     $backupdirmode            = '0700',
  String[1]                                     $backupdirowner           = 'root',
  String[1]                                     $backupdirgroup           = $mysql::params::root_group,
  Boolean                                       $backupcompress           = true,
  Variant[Integer, String[1]]                   $backuprotate             = 30,
  String                                        $backupmethod             = '',
  Optional[String[1]]                           $backup_success_file_path = undef,
  Boolean                                       $ignore_events            = true,
  Boolean                                       $delete_before_dump       = false,
  Array[String[1]]                              $backupdatabases          = [],
  Boolean                                       $file_per_database        = false,
  Boolean                                       $include_triggers         = true,
  Boolean                                       $include_routines         = false,
  Enum['present', 'absent']                     $ensure                   = 'present',
  Variant[Array[String[1]], Array[Integer]]     $time                     = ['23', '5'],
  Variant[Boolean, String[1], Array[String[1]]] $prescript                = false,
  Variant[Boolean, String[1], Array[String[1]]] $postscript               = false,
  String[1]                                     $execpath                 = '/usr/bin:/usr/sbin:/bin:/sbin',
  Array[String[1]]                              $optional_args            = [],
  Boolean                                       $incremental_backups      = false,
  Boolean                                       $install_cron             = true,
  Optional[String[1]]                           $compression_command      = undef,
  Optional[String[1]]                           $compression_extension    = undef,
  Optional[String[1]]                           $backupmethod_package     = undef,
) inherits mysql::params {
  $backuppassword_unsensitive = if $backuppassword =~ Sensitive {
    $backuppassword.unwrap
  } else {
    $backuppassword
  }
  mysql_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => Deferred('mysql::password', [$backuppassword]),
    require       => Class['mysql::server::root_password'],
  }

  package { 'meb':
    ensure    => $ensure,
  }

  # http://dev.mysql.com/doc/mysql-enterprise-backup/3.11/en/mysqlbackup.privileges.html
  mysql_grant { "${backupuser}@localhost/*.*":
    ensure     => $ensure,
    user       => "${backupuser}@localhost",
    table      => '*.*',
    privileges => ['RELOAD', 'SUPER', 'REPLICATION CLIENT'],
    require    => Mysql_user["${backupuser}@localhost"],
  }

  mysql_grant { "${backupuser}@localhost/mysql.backup_progress":
    ensure     => $ensure,
    user       => "${backupuser}@localhost",
    table      => 'mysql.backup_progress',
    privileges => ['CREATE', 'INSERT', 'DROP', 'UPDATE'],
    require    => Mysql_user["${backupuser}@localhost"],
  }

  mysql_grant { "${backupuser}@localhost/mysql.backup_history":
    ensure     => $ensure,
    user       => "${backupuser}@localhost",
    table      => 'mysql.backup_history',
    privileges => ['CREATE', 'INSERT', 'SELECT', 'DROP', 'UPDATE'],
    require    => Mysql_user["${backupuser}@localhost"],
  }

  if $install_cron {
    if $facts['os']['family'] == 'RedHat' {
      stdlib::ensure_packages('cronie')
    } elsif $facts['os']['family'] != 'FreeBSD' {
      stdlib::ensure_packages('cron')
    }
  }

  cron { 'mysqlbackup-weekly':
    ensure  => $ensure,
    command => 'mysqlbackup backup',
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    weekday => '0',
    require => Package['meb'],
  }

  cron { 'mysqlbackup-daily':
    ensure  => $ensure,
    command => 'mysqlbackup --incremental backup',
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    weekday => '1-6',
    require => Package['meb'],
  }

  $default_options = {
    'mysqlbackup' => {
      'backup-dir'             => $backupdir,
      'with-timestamp'         => true,
      'incremental_base'       => 'history:last_backup',
      'incremental_backup_dir' => $backupdir,
      'user'                   => $backupuser,
      'password'               => Deferred('mysql::password', [$backuppassword_unsensitive]),
    },
  }
  $options = mysql::normalise_and_deepmerge($default_options, $mysql::server::override_options)

  file { 'mysqlbackup-config-file':
    path    => '/etc/mysql/conf.d/meb.cnf',
    content => stdlib::deferrable_epp('mysql/meb.cnf.epp', { 'options' => $options }),
    mode    => '0600',
  }

  file { $backupdir:
    ensure => 'directory',
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  }
}
