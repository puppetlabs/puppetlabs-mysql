# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet/util/execution'
require File.expand_path(File.join(File.dirname(__FILE__), 'inifile'))

# Implementation for the mysql_login_path type using the Resource API.
class Puppet::Provider::MysqlLoginPath::MysqlLoginPath < Puppet::ResourceApi::SimpleProvider

  def get_homedir(context, uid)
    result =  Puppet::Util::Execution.execute(['/usr/bin/getent', 'passwd', uid], failonfail: true)
    return result.split(':')[5]
  end

  # return a valid uid for a username or a uid
  #def get_uid(user)
  #  uid = user
  #  if user.is_a? String
  #    result =  Puppet::Util::Execution.execute(['/usr/bin/getent', 'passwd', user], failonfail: true)
  #    uid = result.split(':')[2]
  #  end
  #  return uid
  #end

  def mysql_config_editor_cmd(context, uid, *args)
    args.unshift('/usr/bin/mysql_config_editor')
    homedir = get_homedir(context, uid)
    return Puppet::Util::Execution.execute(
        args,
        failonfail: true,
        uid: uid,
        custom_environment: { 'HOME' => homedir }
    )
  end

  def my_print_defaults_cmd(context, uid, *args)
    args.unshift('/usr/bin/my_print_defaults')
    homedir = get_homedir(context, uid)
    return Puppet::Util::Execution.execute(
        args,
        failonfail: true,
        uid: uid,
        custom_environment: { 'HOME' => homedir })
  end

  def get_password(context, uid, name)
    result = ''
    output = my_print_defaults_cmd(context, uid, '-s', name)
    output.split("\n").each do |line|
      if line.match(/\-\-password/)
        result = line.sub(/\-\-password=/, "")
      end
    end
    result
  end

  def list_login_paths(context, uid)
    result = []
    output = mysql_config_editor_cmd(context, uid, 'print', '--all')
    ini = IniFile.new( :content => output )
    ini.each_section do |section|
      result.push({
                      ensure: 'present',
                      name: section,
                      owner: uid.to_s,
                      title: section + "-" + uid.to_s,
                      host: ini[section]["host"].nil? ? nil : ini[section]["host"],
                      user: ini[section]["user"].nil? ? nil : ini[section]["user"],
                      password: ini[section]["password"].nil? ? nil : get_password(context, uid, section),
                      socket: ini[section]["socket"].nil? ? nil : ini[section]["socket"],
                      port: ini[section]["port"].nil? ? nil : ini[section]["port"],
                  })
    end
    result
  end

  def get(context, name)
    uid = name.first.fetch(:owner)
    login_paths = list_login_paths(context, uid)
    login_paths
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


#var = "[local_socket]\nuser = root\npassword = *****\nhost = localhost\nsocket = /var/run/mysql/mysql.sock\n[local_tcp]\nuser = root\npassword = *****\nhost = 127.0.0.1\nport = 3306\n"
#var = "--user=root\n--password=test123\n--host=127.0.0.1\n--port=3306"