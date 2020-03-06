# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'mysql_login_path',

  docs: <<-EOS,
@summary Manage a MySQL login path.
@example
mysql_login_path { 'foo':
  ensure => 'present',
}

This type provides Puppet with the capabilities to store authentication credentials in an obfuscated login path file 
named .mylogin.cnf created with the mysql_config_editor utility.

EOS
  features: [],
  attributes: {
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    name: {
      type:      'String',
      desc:      'Name of the login path you want to manage.',
      behaviour: :namevar,
    },
    host: {
      type:      'String',
      desc:      'Host name to be entered into the login file.',
    },
    user: {
      type:      'String',
      desc:      'User name to be entered into the login file.',
    },
    password: {
      type:      'String',
      desc:      'Password to be entered into login file',
    },
    socket: {
      type:      'String',
      desc:      'Socket path to be entered into login file',
    },
    port: {
      type:      'Integer[0,65535]',
      desc:      'Port number to be entered into login file.',
    },
  },
)
