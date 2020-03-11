# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet/util/execution'
require 'json'

# Implementation for the mysql_login_path type using the Resource API.
class Puppet::Provider::MysqlLoginPath::MysqlLoginPath < Puppet::ResourceApi::SimpleProvider

  def get_homedir(context, uid)
    result =  Puppet::Util::Execution.execute(['/usr/bin/getent', 'passwd', '1000'], failonfail: true)
    return result.split(':')[5]
  end

  def mysql_config_editor_cmd(context, uid, *args)
    args.unshift('/usr/bin/mysql_config_editor')
    homedir = get_homedir(context, uid)
    return Puppet::Util::Execution.execute(args, failonfail: true, combine: true, uid: uid,
                                           custom_environment: { 'HOME' => homedir }
    )
  end

  def my_print_defaults_cmd(context, *args)
    args.unshift('/usr/bin/my_print_defaults')
    return Puppet::Util::Execution.execute(args, failonfail: true)
  end

  def get_password_for_login_path(context, name)
    result = my_print_defaults_cmd(context, '-s', name)
    puts result
  end

  def list_login_paths(context, uid)
    result = mysql_config_editor_cmd(context, uid, 'print', '--all')
    puts "Command output list login paths"
    puts result
    # parse to json
    return []

  end

  def get(context)
    puts context
    login_paths = list_login_paths(context, 0)
    puts login_paths

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
