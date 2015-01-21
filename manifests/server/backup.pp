# See README.me for usage.
class mysql::server::backup (
  $backupuser,
  $backuppassword,
  $backupdir,
  $backupmethod = 'mysqldump',
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

  mysql_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => mysql_password($backuppassword),
    provider      => 'mysql',
    require       => Class['mysql::server::root_password'],
  }

  case $backupmethod {
    'mysqlbackup': {
      package { 'meb':
        ensure    => $ensure,
      }

      # http://dev.mysql.com/doc/mysql-enterprise-backup/3.11/en/mysqlbackup.privileges.html
      mysql_grant { "${backupuser}@localhost/*.*":
        ensure     => $ensure,
        user       => "${backupuser}@localhost",
        table      => '*.*',
        privileges => [ 'RELOAD', 'SUPER', 'REPLICATION CLIENT' ],
        require    => Mysql_user["${backupuser}@localhost"],
      }

      mysql_grant { "${backupuser}@localhost/mysql.backup_progress":
        ensure     => $ensure,
        user       => "${backupuser}@localhost",
        table      => 'mysql.backup_progress',
        privileges => [ 'CREATE', 'INSERT', 'DROP', 'UPDATE' ],
        require    => Mysql_user["${backupuser}@localhost"],
      }

      mysql_grant { "${backupuser}@localhost/mysql.backup_history":
        ensure     => $ensure,
        user       => "${backupuser}@localhost",
        table      => 'mysql.backup_history',
        privileges => [ 'CREATE', 'INSERT', 'SELECT', 'DROP', 'UPDATE' ],
        require    => Mysql_user["${backupuser}@localhost"],
      }

      cron { 'mysqlbackup-weekly':
        ensure  => $ensure,
        command => 'mysqlbackup backup',
        user    => 'root',
        hour    => $time[0],
        minute  => $time[1],
        weekday => 0,
        require => Package['meb'],
      }

      cron { 'mysqlbackup-daily':
        ensure  => $ensure,
        command => 'mysqlbackup --incremental backup',
        user    => 'root',
        hour    => $time[0],
        minute  => $time[1],
        weekday => 1-6,
        require => Package['meb'],
      }
    }
    'xtrabackup': {
      package{ 'percona-xtrabackup':
        ensure  => $ensure,
      }
      cron { 'xtrabackup-weekly':
        ensure  => $ensure,
        command => 'innobackupex $backupdir',
        user    => 'root',
        hour    => $time[0],
        minute  => $time[1],
        weekday => 0,
        require => Package['percona-xtrabackup'],
      }
      cron { 'xtrabackup-daily':
        ensure  => $ensure,
        command => 'innobackupex --incremental $backupdir',
        user    => 'root',
        hour    => $time[0],
        minute  => $time[1],
        weekday => 1-6,
        require => Package['percona-xtrabackup'],
      }
    }
    default: {
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
    }
  }

  file { 'mysqlbackupdir':
    ensure => 'directory',
    path   => $backupdir,
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  }

}
