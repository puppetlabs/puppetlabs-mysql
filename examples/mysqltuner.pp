# @summary
#   Manage the MySQLTuner package.

$version = 'v1.3.0'

file { '/usr/local/bin/mysqltuner':
  ensure => 'file',
  owner  => 'root',
  group  => 'root',
  mode   => '0550',
  source => "https://github.com/major/MySQLTuner-perl/raw/${version}/mysqltuner.pl",
}
