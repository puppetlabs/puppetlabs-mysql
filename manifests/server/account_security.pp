# @summary
#   Private class for ensuring localhost accounts do not exist
#
# @api private
#
class mysql::server::account_security {
  mysql_user {
    ['root@127.0.0.1',
      'root@::1',
      '@localhost',
    '@%']:
      ensure  => 'absent',
      require => Anchor['mysql::server::end'],
  }
  if ($facts['networking']['fqdn'] != 'localhost.localdomain') {
    mysql_user {
      ['root@localhost.localdomain',
      '@localhost.localdomain']:
        ensure  => 'absent',
        require => Anchor['mysql::server::end'],
    }
  }
  if ($facts['networking']['fqdn'] and $facts['networking']['fqdn'] != 'localhost') {
    mysql_user {
      ["root@${facts['networking']['fqdn']}",
      "@${facts['networking']['fqdn']}"]:
        ensure  => 'absent',
        require => Anchor['mysql::server::end'],
    }
  }
  if ($facts['networking']['fqdn'] != $facts['networking']['hostname']) {
    if ($facts['networking']['hostname'] != 'localhost') {
      mysql_user { ["root@${facts['networking']['hostname']}", "@${facts['networking']['hostname']}"]:
        ensure  => 'absent',
        require => Anchor['mysql::server::end'],
      }
    }
  }
  mysql_database { 'test':
    ensure  => 'absent',
    require => Anchor['mysql::server::end'],
  }
}
