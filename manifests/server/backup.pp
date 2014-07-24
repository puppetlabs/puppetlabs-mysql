# See README.me for usage.
class mysql::server::backup (
  $backupuser,
  $backupdir,
  $backuppassword = undef,
  $backupdirmode = '0700',
  $backupdirowner = 'root',
  $backupdirgroup = 'root',
  $backupcompress = true,
  $backuprotate = 30,
  $ignore_events = true,
  $delete_before_dump = false,
  $backupdatabases = [],
  $file_per_database = false,
  $ensure = 'present',
  $time = ['23', '5'],
  $postscript = false,
  $execpath   = '/usr/bin:/usr/sbin:/bin:/sbin',
) {

  if $ensure != 'absent' and !$backuppassword {
    fail("${class_name} 'backuppassword' must be set.")
  }

  $mysql_user_require = $ensure ? {
    'absent' => undef,
    default  => Class['mysql::server::root_password'],
  }

  mysql_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => mysql_password($backuppassword),
    provider      => 'mysql',
    require       => $mysql_user_require,
  }

  mysql_grant { "${backupuser}@localhost/*.*":
    ensure     => $ensure,
    user       => "${backupuser}@localhost",
    table      => '*.*',
    privileges => [ 'SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'PROCESS' ],
    require    => Mysql_user["${backupuser}@localhost"],
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
    group   => 'root',
    content => template('mysql/mysqlbackup.sh.erb'),
  }

  $directory_ensure = $ensure ? {
    'absent' => $ensure,
    default  => 'directory',
  }

  file { 'mysqlbackupdir':
    ensure => $directory_ensure,
    path   => $backupdir,
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  }

}
