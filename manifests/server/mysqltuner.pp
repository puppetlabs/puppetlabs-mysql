#
class mysql::server::mysqltuner(
  $ensure  = 'present',
  $version = 'v1.3.0',
  $source  = undef,
) {

  if $source {
    $_source  = $source
  } else {
    $_source  = "https://github.com/major/MySQLTuner-perl/raw/${version}/mysqltuner.pl"
  }

  archive { '/usr/local/bin/mysqltuner':
    ensure => $ensure,
    source => $_source,
  }
  file { '/usr/local/bin/mysqltuner':
    mode   => '0550',
  }
}
