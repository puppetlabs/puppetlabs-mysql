# See README.me for usage.
class mysql::backup::xtrabackup (
  $backupuser         = '',
  $backuppassword     = '',
  $backupdir          = '',
  $backupmethod       = 'mysqldump',
  $backupdirmode      = '0700',
  $backupdirowner     = 'root',
  $backupdirgroup     = $mysql::params::root_group,
  $backupcompress     = true,
  $backuprotate       = 30,
  $ignore_events      = true,
  $delete_before_dump = false,
  $backupdatabases    = [],
  $file_per_database  = false,
  $include_triggers   = true,
  $include_routines   = false,
  $ensure             = 'present',
  $time               = ['23', '5'],
  $prescript          = false,
  $postscript         = false,
  $execpath           = '/usr/bin:/usr/sbin:/bin:/sbin',
  $template           = 'mysql/xtrabackup.sh.erb',
  $template_params    = {},
) {

  # we do not use a default value in the class variable to have the possibility to use mysql::server::backup as a facade
  if $template {
    $template_set = $template
  }else{
    $template_set = 'mysql/xtrabackup.sh.erb'
  }

  package{ 'percona-xtrabackup':
    ensure  => $ensure,
  }

  cron { 'xtrabackup-weekly':
    ensure  => $ensure,
    command => "/usr/local/sbin/xtrabackup.sh ${backupdir} 2>&1 | logger -t mysqlbackup # see syslog",
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    weekday => '0',
    require => Package['percona-xtrabackup'],
  }

  cron { 'xtrabackup-daily':
    ensure  => $ensure,
    command => "/usr/local/sbin/xtrabackup.sh --incremental ${backupdir} 2>&1 |  logger -t mysqlbackup # see syslog",
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    weekday => '1-6',
    require => Package['percona-xtrabackup'],
  }

  file { 'mysqlbackupdir':
    ensure => 'directory',
    path   => $backupdir,
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
    content => template($template_set),
  }
}
