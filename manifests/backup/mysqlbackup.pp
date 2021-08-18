# @summary
#   Manage the mysqlbackup client.
#
# @api private
#
class mysql::backup::mysqlbackup (
  $backupuser               = '',
  Variant[String, Sensitive[String]] $backuppassword = '',
  $maxallowedpacket         = '1M',
  $backupdir                = '',
  $backupdirmode            = '0700',
  $backupdirowner           = 'root',
  $backupdirgroup           = $mysql::params::root_group,
  $backupcompress           = true,
  $backuprotate             = 30,
  $backupmethod             = '',
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
  $incremental_backups      = false,
  $install_cron             = true,
  $compression_command      = undef,
  $compression_extension    = undef,
) inherits mysql::params {
  $backuppassword_unsensitive = if $backuppassword =~ Sensitive {
    $backuppassword.unwrap
  } else {
    $backuppassword
  }
  mysql_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => mysql::password($backuppassword),
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
    if $::osfamily == 'RedHat' {
      ensure_packages('cronie')
    } elsif $::osfamily != 'FreeBSD' {
      ensure_packages('cron')
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
      'password'               => $backuppassword_unsensitive
    },
  }
  $options = mysql::normalise_and_deepmerge($default_options, $mysql::server::override_options)

  file { 'mysqlbackup-config-file':
    path    => '/etc/mysql/conf.d/meb.cnf',
    content => template('mysql/meb.cnf.erb'),
    mode    => '0600',
  }

  file { $backupdir:
    ensure => 'directory',
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  }
}
