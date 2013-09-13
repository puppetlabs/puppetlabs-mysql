#
class mysql::server::mysqltuner {
  # mysql performance tester
  file { '/usr/local/bin/mysqltuner':
    ensure  => present,
    mode    => '0550',
    source  => 'puppet:///modules/mysql/mysqltuner.pl',
  }
}
