# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet/util/execution'
require 'json'

# Implementation for the mysql_login_path type using the Resource API.
class Puppet::Provider::MysqlLoginPath::MysqlLoginPath < Puppet::ResourceApi::SimpleProvider

  def mysql_config_editor_cmd(context, *args)
    args.unshift('/usr/bin/mysql_config_editor')
    return Puppet::Util::Execution.execute(args, failonfail: true)
  end

  def my_print_defaults_cmd(context, *args)
    args.unshift('/usr/bin/my_print_defaults')
    return Puppet::Util::Execution.execute(args, failonfail: true)
  end

  def get_password_for_login_path(context, name)
#    my_print_defaults -s local_tcp
#    --user=root
#    --password=test123
#    --host=127.0.0.1
#    --port=3306
    result = my_print_defaults_cmd(context, '-s', name)
    puts result
  end

  def list_login_paths(context)
    result = mysql_config_editor_cmd(context, 'print', '--all')
    puts result
  end

  def get(context)
    login_paths = list_login_paths(context)
    puts "Hello"
    context.debug('Returning pre-canned example data')
    [
      {
        name: 'foo',
        ensure: 'present',
      },
      {
        name: 'bar',
        ensure: 'present',
      },
    ]
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")
  end
end
