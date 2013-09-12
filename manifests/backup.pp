# Class: mysql::backup
#
# This module handles ...
#
# Parameters:
#   [*backupuser*]         - The name of the mysql backup user.
#   [*backuppassword*]     - The password of the mysql backup user.
#   [*backupdir*]          - The target directory of the mysqldump.
#   [*backupcompress*]     - Boolean to compress backup with bzip2.
#   [*backuprotate*]       - Number of backups to keep. Default 30
#   [*backupday*]          - Cron weekdays. Default *
#   [*backuphour*]         - Cron hout. Default 23
#   [*backupmin*]          - Cron minute. Default 5
#   [*backupdatabases*]    - Specify databases to back up as array (default all)
#   [*file_per_database*]  - Boolean to dump each database to its own file.
#   [*delete_before_dump*] - Clean existing backups before creating new
#
# Actions:
#   GRANT SELECT, RELOAD, LOCK TABLES ON *.* TO 'user'@'localhost'
#    IDENTIFIED BY 'password';
#
# Requires:
#   Class['mysql::config']
#
# Sample Usage:
#   class { 'mysql::backup':
#     backupuser     => 'myuser',
#     backuppassword => 'mypassword',
#     backupdir      => '/tmp/backups',
#     backupcompress => true,
#   }
#
class mysql::backup (
  $backupuser,
  $backuppassword,
  $backupdir,
  $backupcompress = true,
  $backuprotate = 30,
  $backuday = '*',
  $backuphour = 23,
  $backupmin = 5,
  $delete_before_dump = false,
  $backupdatabases = [],
  $file_per_database = false,
  $ensure = 'present'
) {

  mysql_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => mysql_password($backuppassword),
    provider      => 'mysql',
    require       => Class['mysql::config'],
  }

  mysql_grant { "${backupuser}@localhost/*.*":
    ensure     => present,
    user       => "${backupuser}@localhost",
    table      => '*.*',
    privileges => [ 'SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW' ],
    require    => Mysql_user["${backupuser}@localhost"],
  }

  cron { 'mysql-backup':
    ensure  => $ensure,
    command => '/usr/local/sbin/mysqlbackup.sh',
    user    => 'root',
    weekday	=> $backupday,
    hour    => $backuphour,
    minute  => $backupmin,
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

  file { 'mysqlbackupdir':
    ensure => 'directory',
    path   => $backupdir,
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  }

}
