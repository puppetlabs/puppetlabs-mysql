# @summary
#   Create and manage a MySQL backup.
#
# @example Create a basic MySQL backup:
#   class { 'mysql::server':
#     root_password           => 'password'
#   }
#   class { 'mysql::server::backup':
#     backupuser              => 'myuser',
#     backuppassword          => 'mypassword',
#     backupdir               => '/tmp/backups',
#   }
#
# @example Create a basic MySQL backup using mariabackup:
#   class { 'mysql::server':
#     root_password           => 'password'
#   }
#   class { 'mysql::server::backup':
#     backupmethod            => 'mariabackup',
#     backupmethod_package    => 'mariadb-backup'
#     provider                => 'xtrabackup',
#     backupdir               => '/tmp/backups',
#   }
#
# @param backupuser
#   MySQL user to create with backup administrator privileges.
# @param backuppassword
#   Password to create for `backupuser`.
# @param backupdir
#   Directory to store backup.
# @param backupdirmode
#   Permissions applied to the backup directory. This parameter is passed directly to the file resource.
# @param backupdirowner
#   Owner for the backup directory. This parameter is passed directly to the file resource.
# @param backupdirgroup
#   Group owner for the backup directory. This parameter is passed directly to the file resource.
# @param backupcompress
#   Whether or not to compress the backup (when using the mysqldump or xtrabackup provider)
# @param backupmethod
#   The execution binary for backing up. ex. mysqldump, xtrabackup, mariabackup
# @param backup_success_file_path
#   Specify a path where upon successfull backup a file should be created for checking purposes.
# @param backuprotate
#   Backup rotation interval in 24 hour periods.
# @param ignore_events
#   Ignore the mysql.event table.
# @param delete_before_dump
#   Whether to delete old .sql files before backing up. Setting to true deletes old files before backing up, while setting to false deletes them after backup.
# @param backupdatabases
#   Databases to backup (required if using xtrabackup provider). By default `[]` will back up all databases.
# @param file_per_database
#   Use file per database mode creating one file per database backup.
# @param include_routines
#   Dump stored routines (procedures and functions) from dumped databases when doing a `file_per_database` backup.
# @param include_triggers
#   Dump triggers for each dumped table when doing a `file_per_database` backup.
# @param incremental_backups
#   A flag to activate/deactivate incremental backups. Currently only supported by the xtrabackup provider.
# @param ensure
# @param time
#   An array of two elements to set the backup time. Allows ['23', '5'] (i.e., 23:05) or ['3', '45'] (i.e., 03:45) for HH:MM times.
# @param prescript
#   A script that is executed before the backup begins.
# @param postscript
#   A script that is executed when the backup is finished. This could be used to sync the backup to a central store. This script can be either a single line that is directly executed or a number of lines supplied as an array. It could also be one or more externally managed (executable) files.
# @param execpath
#   Allows you to set a custom PATH should your MySQL installation be non-standard places. Defaults to `/usr/bin:/usr/sbin:/bin:/sbin`.
# @param provider
#   Sets the server backup implementation. Valid values are: xtrabackup, mysqldump, mysqlbackup
# @param maxallowedpacket
#   Defines the maximum SQL statement size for the backup dump script. The default value is 1MB, as this is the default MySQL Server value.
# @param optional_args
#   Specifies an array of optional arguments which should be passed through to the backup tool. (Supported by the xtrabackup and mysqldump providers.)
# @param install_cron
#   Manage installation of cron package
# @param compression_command
#   Configure the command used to compress the backup (when using the mysqldump provider). Make sure the command exists
#   on the target system. Packages for it are NOT automatically installed.
# @param compression_extension
#   Configure the file extension for the compressed backup (when using the mysqldump provider)
# @param backupmethod_package
#   The package which provides the binary specified by the backupmethod parameter.
# @param excludedatabases
#   Give a list of excluded databases when using file_per_database, e.g.: [ 'information_schema', 'performance_schema' ]
class mysql::server::backup (
  $backupuser               = undef,
  Optional[Variant[String, Sensitive[String]]] $backuppassword = undef,
  $backupdir                = undef,
  $backupdirmode            = '0700',
  $backupdirowner           = 'root',
  $backupdirgroup           = $mysql::params::root_group,
  $backupcompress           = true,
  $backuprotate             = 30,
  $backupmethod             = undef,
  $backup_success_file_path = '/tmp/mysqlbackup_success',
  $ignore_events            = true,
  $delete_before_dump       = false,
  $backupdatabases          = [],
  $file_per_database        = false,
  $include_routines         = false,
  $include_triggers         = false,
  $ensure                   = 'present',
  $time                     = ['23', '5'],
  $prescript                = false,
  $postscript               = false,
  $execpath                 = '/usr/bin:/usr/sbin:/bin:/sbin',
  $provider                 = 'mysqldump',
  $maxallowedpacket         = '1M',
  $optional_args            = [],
  $incremental_backups      = true,
  $install_cron             = true,
  $compression_command      = undef,
  $compression_extension    = undef,
  $backupmethod_package     = $mysql::params::xtrabackup_package_name,
  Array[String] $excludedatabases = [],
) inherits mysql::params {
  if $prescript and $provider =~ /(mysqldump|mysqlbackup)/ {
    warning("The 'prescript' option is not currently implemented for the ${provider} backup provider.")
  }

  create_resources('class', {
      "mysql::backup::${provider}" => {
        'backupuser'               => $backupuser,
        'backuppassword'           => $backuppassword,
        'backupdir'                => $backupdir,
        'backupdirmode'            => $backupdirmode,
        'backupdirowner'           => $backupdirowner,
        'backupdirgroup'           => $backupdirgroup,
        'backupcompress'           => $backupcompress,
        'backuprotate'             => $backuprotate,
        'backupmethod'             => $backupmethod,
        'backup_success_file_path' => $backup_success_file_path,
        'ignore_events'            => $ignore_events,
        'delete_before_dump'       => $delete_before_dump,
        'backupdatabases'          => $backupdatabases,
        'file_per_database'        => $file_per_database,
        'include_routines'         => $include_routines,
        'include_triggers'         => $include_triggers,
        'ensure'                   => $ensure,
        'time'                     => $time,
        'prescript'                => $prescript,
        'postscript'               => $postscript,
        'execpath'                 => $execpath,
        'maxallowedpacket'         => $maxallowedpacket,
        'optional_args'            => $optional_args,
        'incremental_backups'      => $incremental_backups,
        'install_cron'             => $install_cron,
        'compression_command'      => $compression_command,
        'compression_extension'    => $compression_extension,
        'backupmethod_package'     => $backupmethod_package,
        'excludedatabases'         => $excludedatabases,
      }
  })
}
