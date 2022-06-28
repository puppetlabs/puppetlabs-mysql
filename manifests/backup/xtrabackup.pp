# @summary
#   "Provider" for Percona XtraBackup/MariaBackup
# @api private
#
class mysql::backup::xtrabackup (
  $backupuser               = undef,
  Optional[Variant[String, Sensitive[String]]] $backuppassword = undef,
  $backupdir                = '',
  $maxallowedpacket         = '1M',
  $backupmethod             = 'xtrabackup',
  $backupdirmode            = '0700',
  $backupdirowner           = 'root',
  $backupdirgroup           = $mysql::params::root_group,
  $backupcompress           = true,
  $backuprotate             = 30,
  $backupscript_template    = 'mysql/xtrabackup.sh.erb',
  $backup_success_file_path = undef,
  $ignore_events            = true,
  $delete_before_dump       = false,
  $backupdatabases          = [],
  $file_per_database        = false,
  $include_triggers         = true,
  $include_routines         = false,
  $ensure                   = 'present',
  $time                     = ['23', '5'],
  $prescript                = false,
  $postscript               = false,
  $execpath                 = '/usr/bin:/usr/sbin:/bin:/sbin',
  $optional_args            = [],
  $additional_cron_args     = '--backup',
  $incremental_backups      = true,
  $install_cron             = true,
  $compression_command      = undef,
  $compression_extension    = undef,
  $backupmethod_package     = $mysql::params::xtrabackup_package_name,
  Array[String] $excludedatabases = [],
) inherits mysql::params {
  ensure_packages($backupmethod_package)

  $backuppassword_unsensitive = if $backuppassword =~ Sensitive {
    $backuppassword.unwrap
  } else {
    $backuppassword
  }

  if $backupuser and $backuppassword {
    mysql_user { "${backupuser}@localhost":
      ensure        => $ensure,
      password_hash => mysql::password($backuppassword),
      require       => Class['mysql::server::root_password'],
    }
    # Percona XtraBackup needs additional grants/privileges to work with MySQL 8
    if versioncmp($facts['mysql_version'], '8') >= 0 and !(/(?i:mariadb)/ in $facts['mysqld_version']) {
      if ($facts['os']['name'] == 'Debian' and versioncmp($facts['os']['release']['major'], '11') >= 0) or
      ($facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['major'], '22.04') >= 0) {
        mysql_grant { "${backupuser}@localhost/*.*":
          ensure     => $ensure,
          user       => "${backupuser}@localhost",
          table      => '*.*',
          privileges => ['BINLOG MONITOR', 'RELOAD', 'PROCESS', 'LOCK TABLES', 'BACKUP_ADMIN'],
          require    => Mysql_user["${backupuser}@localhost"],
        }
      }
      else {
        mysql_grant { "${backupuser}@localhost/*.*":
          ensure     => $ensure,
          user       => "${backupuser}@localhost",
          table      => '*.*',
          privileges => ['RELOAD', 'PROCESS', 'LOCK TABLES', 'REPLICATION CLIENT', 'BACKUP_ADMIN'],
          require    => Mysql_user["${backupuser}@localhost"],
        }
      }
      mysql_grant { "${backupuser}@localhost/performance_schema.keyring_component_status":
        ensure     => $ensure,
        user       => "${backupuser}@localhost",
        table      => 'performance_schema.keyring_component_status',
        privileges => ['SELECT'],
        require    => Mysql_user["${backupuser}@localhost"],
      }
      mysql_grant { "${backupuser}@localhost/performance_schema.log_status":
        ensure     => $ensure,
        user       => "${backupuser}@localhost",
        table      => 'performance_schema.log_status',
        privileges => ['SELECT'],
        require    => Mysql_user["${backupuser}@localhost"],
      }
    }
    else {
      if $facts['os']['family'] == 'debian' and $facts['os']['release']['major'] == '11' or
      ($facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['major'], '22.04') >= 0) {
        mysql_grant { "${backupuser}@localhost/*.*":
          ensure     => $ensure,
          user       => "${backupuser}@localhost",
          table      => '*.*',
          privileges => ['BINLOG MONITOR', 'RELOAD', 'PROCESS', 'LOCK TABLES'],
          require    => Mysql_user["${backupuser}@localhost"],
        }
      }
      else {
        mysql_grant { "${backupuser}@localhost/*.*":
          ensure     => $ensure,
          user       => "${backupuser}@localhost",
          table      => '*.*',
          privileges => ['RELOAD', 'PROCESS', 'LOCK TABLES', 'REPLICATION CLIENT'],
          require    => Mysql_user["${backupuser}@localhost"],
        }
      }
    }
  }

  if $install_cron {
    if $::osfamily == 'RedHat' {
      ensure_packages('cronie')
    } elsif $::osfamily != 'FreeBSD' {
      ensure_packages('cron')
    }
  }

  if $incremental_backups {
    # Warn if old backups are removed too soon. Incremental backups will fail
    # if the full backup is no longer available.
    if ($backuprotate.convert_to(Integer) < 7) {
      warning('The value for `backuprotate` is too low, it must be set to at least 7 days when using incremental backups.')
    }

    # The --target-dir uses a more predictable value for the full backup so
    # that it can easily be calculated and used in incremental backup jobs.
    # Besides that it allows to have multiple full backups.
    cron { 'xtrabackup-weekly':
      ensure  => $ensure,
      command => "/usr/local/sbin/xtrabackup.sh --target-dir=${backupdir}/$(date +\\%F)_full ${additional_cron_args}",
      user    => 'root',
      hour    => $time[0],
      minute  => $time[1],
      weekday => '0',
      require => Package[$backupmethod_package],
    }
  }

  # Wether to use GNU or BSD date format.
  case $::osfamily {
    'FreeBSD','OpenBSD': {
      $dateformat = '$(date -v-sun +\\%F)_full'
    }
    default: {
      $dateformat = '$(date -d "last sunday" +\\%F)_full'
    }
  }

  $daily_cron_data = ($incremental_backups) ? {
    true  => {
      'directories' => "--incremental-basedir=${backupdir}/${dateformat} --target-dir=${backupdir}/$(date +\\%F_\\%H-\\%M-\\%S)",
      'weekday'     => '1-6',
    },
    false => {
      'directories' => "--target-dir=${backupdir}/$(date +\\%F_\\%H-\\%M-\\%S)",
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
    require => Package[$backupmethod_package],
  }

  file { $backupdir:
    ensure => 'directory',
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  }

  # TODO: use EPP instead of ERB, as EPP can handle Data of Type Sensitive without further ado
  file { 'xtrabackup.sh':
    ensure  => $ensure,
    path    => '/usr/local/sbin/xtrabackup.sh',
    mode    => '0700',
    owner   => 'root',
    group   => $mysql::params::root_group,
    content => template($backupscript_template),
  }
}
