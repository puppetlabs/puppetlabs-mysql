# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'mysql_login_path',

  docs: <<-DESCRIPTION,
  @summary
    Manage a MySQL login path.
  @see
    https://dev.mysql.com/doc/refman/8.0/en/mysql-config-editor.html
  @example
    mysql_login_path { 'local_socket':
      owner    => 'root',
      host     => 'localhost',
      user     => 'root',
      password => Sensitive('secure'),
      socket   => '/var/run/mysql/mysql.sock',
      ensure   => present,
    }

    mysql_login_path { 'local_tcp':
      owner    => 'root',
      host     => '127.0.0.1',
      user     => 'root',
      password => Sensitive('more_secure'),
      port     => 3306,
      ensure   => present,
    }

  This type provides Puppet with the capabilities to store authentication credentials in an obfuscated login path file
  named .mylogin.cnf created with the mysql_config_editor utility. Supports only MySQL Community Edition > v5.6.6.
  DESCRIPTION
  features: ['simple_get_filter', 'canonicalize'],
  title_patterns: [
    {
      pattern: %r{^(?<name>.*[^-])-(?<owner>.*)$},
      desc: 'Where the name of the and the owner are provided with a hyphen seperator'
    },
    {
      pattern: %r{^(?<name>.*)$},
      desc: 'Where only the name is provided'
    },
  ],
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Whether this resource should be present or absent on the target system.'
    },
    name: {
      type: 'String',
      desc: 'Name of the login path you want to manage.',
      behaviour: :namevar
    },
    owner: {
      type: 'String',
      desc: 'The user to whom the logon path should belong.',
      behaviour: :namevar,
      default: 'root'
    },
    host: {
      type: 'Optional[String]',
      desc: 'Host name to be entered into the login path.'
    },
    user: {
      type: 'Optional[String]',
      desc: 'Username to be entered into the login path.'
    },
    password: {
      type: 'Optional[Sensitive[String[1]]]',
      desc: 'Password to be entered into login path'
    },
    socket: {
      type: 'Optional[String]',
      desc: 'Socket path to be entered into login path'
    },
    port: {
      type: 'Optional[Integer[0,65535]]',
      desc: 'Port number to be entered into login path.'
    }
  },
)
