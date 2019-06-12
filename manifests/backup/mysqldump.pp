# @summary
#   "Provider" for mysqldump
# @api private
#
class mysql::backup::mysqldump (
  $backupcompress        = true,
  $backupdatabases       = [],
  $backupdir             = '',
  $backupdirgroup        = $mysql::params::root_group,
  $backupdirmode         = '0700',
  $backupdirowner        = 'root',
  $backupmethod          = 'mysqldump',
  $backuppassword        = '',
  $backuprotate          = 30,
  $backupuser            = '',
  $delete_before_dump    = false,
  $ensure                = 'present',
  $execpath              = '/usr/bin:/usr/sbin:/bin:/sbin',
  $file_per_database     = false,
  $ignore_events         = true,
  $include_routines      = false,
  $include_triggers      = false,
  $manage_package_cron   = $mysql::server::backup::manage_package_cron,
  $maxallowedpacket      = '1M',
  $mysqlbackupdir_ensure = 'directory',
  $mysqlbackupdir_target = undef,
  $optional_args         = [],
  $postscript            = false,
  $prescript             = false,
  $time                  = ['23', '5'],
) inherits mysql::params {

  if $backupcompress {
    ensure_packages(['bzip2'])
    Package['bzip2'] -> File['mysqlbackup.sh']
  }

  mysql_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => mysql::password($backuppassword),
    require       => Class['mysql::server::root_password'],
  }

  if $include_triggers  {
    $privs = [ 'SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'PROCESS', 'TRIGGER' ]
  } else {
    $privs = [ 'SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'PROCESS' ]
  }

  mysql_grant { "${backupuser}@localhost/*.*":
    ensure     => $ensure,
    user       => "${backupuser}@localhost",
    table      => '*.*',
    privileges => $privs,
    require    => Mysql_user["${backupuser}@localhost"],
  }

  if $manage_package_cron {
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '5' {
      package {'crontabs':
        ensure => present,
      }
    } elsif $::osfamily == 'RedHat' {
      package {'cronie':
        ensure => present,
      }
    } else {
      package {'cron':
        ensure => present,
      }
    }
  }

  cron { 'mysql-backup':
    ensure  => $ensure,
    command => '/usr/local/sbin/mysqlbackup.sh',
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    require => File['mysqlbackup.sh'],
  }

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
