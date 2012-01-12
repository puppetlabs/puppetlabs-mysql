# Class: mysql::timezone
#
# manages the timezone tables in MySQL
# See http://dev.mysql.com/doc/refman/5.5/en/time-zone-support.html
#
# Parameters:
#   [none]
#
# Actions:
#
# Requires:
#   Class['mysql::server']
#
# Sample Usage:
#   include mysql::timezone

class mysql::timezone {
  Class['mysql::server'] -> Class['mysql::timezone']

  package { 'tzdata':
    ensure => latest
  }

  $zoneinfo_dir = '/usr/share/zoneinfo'

  $tzinfo_sql = '/var/run/mysqld/tzinfo.sql'
  file { $tzinfo_sql: ensure => file }

  Exec { path => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'] }

  exec {
    "mysql_tzinfo_to_sql ${zoneinfo_dir} > ${tzinfo_sql}":
      user        => 'root',
      refreshonly => true,
      # We want to regenerate the sql whenever /usr/share/zoneinfo is updated,
      # but checksumming the directory is painfully slow.  Subscribing to the
      # file /var/run/mysqld/tzinfo.sql and having puppet create this file if
      # it doesn't exist ensures we don't have to wait for an update to the
      # tzdata package.
      subscribe   => [Package['tzdata'], File[$tzinfo_sql]];
    "mysql --defaults-file=/root/.my.cnf mysql < ${tzinfo_sql}":
      user        => 'root',
      refreshonly => true,
      subscribe  => File[$tzinfo_sql];
  }
}
