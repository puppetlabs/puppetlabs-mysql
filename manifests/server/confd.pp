# Define: mysql::server::confd:  See README.md for documentation.
define mysql::server::confd (
  $content = undef,
  $source = undef,
) {
  file { "/etc/mysql/conf.d/${name}.cnf":
    ensure  => file,
    content => $content,
    source  => $source,
    require => Class['mysql::server::config'],
  }

  if $::mysql::server::restart {
    File["/etc/mysql/conf.d/${name}.cnf"] ~> Class['mysql::server::service']
  }
}
