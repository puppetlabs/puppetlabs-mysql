# @summary
#   Manage the MySQLTuner package.
#
# @param ensure
#   Ensures that the resource exists. Valid values are 'present', 'absent'. Defaults to 'present'.
# @param version
#   The version to install from the major/MySQLTuner-perl github repository. Must be a valid tag. Defaults to 'v1.3.0'.
# @param source
#   Source path for the mysqltuner package.
# @param tuner_location
#   Destination for the mysqltuner package.
class mysql::server::mysqltuner(
  $ensure  = 'present',
  $version = 'v1.3.0',
  $source  = undef,
  $tuner_location = '/usr/local/bin/mysqltuner',
) {
  if $source {
    $_source  = $source
  } else {
    $_source  = "https://github.com/major/MySQLTuner-perl/raw/${version}/mysqltuner.pl"
  }
  file { $tuner_location:
    ensure => $ensure,
    mode   => '0550',
    source => $_source,
  }
}
