# @summary
#   "Provider" for Percona XtraBackup/MariaBackup
# @api private
#
class mysql::backup::xtrabackup (
  $additional_cron_args    = '--backup',
  $backupcompress          = true,
  $backupdatabases         = [],
  $backupdir               = '',
  $backupdirgroup          = $mysql::params::root_group,
  $backupdirmode           = '0700',
  $backupdirowner          = 'root',
  $backupmethod            = 'xtrabackup',
  $backuppassword          = undef,
  $backuprotate            = 30,
  $backupscript_template   = 'mysql/xtrabackup.sh.erb',
  $backupuser              = undef,
  $delete_before_dump      = false,
  $ensure                  = 'present',
  $execpath                = '/usr/bin:/usr/sbin:/bin:/sbin',
  $file_per_database       = false,
  $ignore_events           = true,
  $include_routines        = false,
  $include_triggers        = true,
  $incremental_backups     = true,
  $manage_package_cron     = $mysql::server::backup::manage_package_cron,
  $maxallowedpacket        = '1M',
  $optional_args           = [],
  $postscript              = false,
  $prescript               = false,
  $time                    = ['23', '5'],
  $xtrabackup_package_name = $mysql::params::xtrabackup_package_name,
) inherits mysql::params {

  ensure_packages($xtrabackup_package_name)

  if $backupuser and $backuppassword {
    mysql_user { "${backupuser}@localhost":
      ensure        => $ensure,
      password_hash => mysql::password($backuppassword),
      require       => Class['mysql::server::root_password'],
    }

    mysql_grant { "${backupuser}@localhost/*.*":
      ensure     => $ensure,
      user       => "${backupuser}@localhost",
      table      => '*.*',
      privileges => [ 'RELOAD', 'PROCESS', 'LOCK TABLES', 'REPLICATION CLIENT' ],
      require    => Mysql_user["${backupuser}@localhost"],
    }
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

  if $incremental_backups {
    cron { 'xtrabackup-weekly':
      ensure  => $ensure,
      command => "/usr/local/sbin/xtrabackup.sh --target-dir=${backupdir} ${additional_cron_args}",
      user    => 'root',
      hour    => $time[0],
      minute  => $time[1],
      weekday => '0',
      require => Package[$xtrabackup_package_name],
    }
  }

  $daily_cron_data = ($incremental_backups) ? {
    true  => {
      'directories' => "--incremental-basedir=${backupdir} --target-dir=${backupdir}/`date +%F_%H-%M-%S`",
      'weekday'     => '1-6',
    },
    false => {
      'directories' => "--target-dir=${backupdir}",
      'weekday'     => '*',
    },
  }

  cron { 'xtrabackup-daily':
    ensure  => $ensure,
    command => "/usr/local/sbin/xtrabackup.sh ${daily_cron_data['directories']} ${additional_cron_args}",
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    weekday => $daily_cron_data['weekday'],
    require => Package[$xtrabackup_package_name],
  }

  file { $backupdir:
    ensure => 'directory',
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  }

  file { 'xtrabackup.sh':
    ensure  => $ensure,
    path    => '/usr/local/sbin/xtrabackup.sh',
    mode    => '0700',
    owner   => 'root',
    group   => $mysql::params::root_group,
    content => template($backupscript_template),
  }
}
