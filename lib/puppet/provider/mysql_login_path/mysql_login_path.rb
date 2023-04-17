# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), 'inifile'))
require File.expand_path(File.join(File.dirname(__FILE__), 'sensitive'))
require 'puppet/resource_api/simple_provider'
require 'puppet/util/execution'
require 'puppet/util/suidmanager'
require 'open3'
require 'pty'
require 'expect'
require 'fileutils'
require 'English'

# Implementation for the mysql_login_path type using the Resource API.
class Puppet::Provider::MysqlLoginPath::MysqlLoginPath < Puppet::ResourceApi::SimpleProvider
  def get_homedir(_context, uid)
    result = Puppet::Util::Execution.execute(['/usr/bin/getent', 'passwd', uid], failonfail: true)
    result.split(':')[5]
  end

  def mysql_config_editor_set_cmd(context, uid, password = nil, *args)
    args.unshift('/usr/bin/mysql_config_editor')
    homedir = get_homedir(context, uid)
    login_file_path = "#{homedir}/.mylogin.cnf"

    if args.is_a?(Array)
      command = args.flatten.map(&:to_s)
      command_str = command.join(' ')
    elsif args.is_a?(String)
      command_str = command
    end

    begin
      Puppet::Util::SUIDManager.asuser(uid) do
        FileUtils.touch login_file_path
        FileUtils.chmod 0o600, login_file_path
      end

      PTY.spawn({ 'HOME' => homedir }, command_str) do |input, output, _pid|
        if password
          input.expect(%r{Enter password:})
          output.puts password
        end
      end
    rescue StandardError => e
      raise Puppet::ExecutionFailure, _(
        "Execution of '%{str}' returned %{exit_status}: %{output}",
      ) % {
        str: command_str,
        exit_status: $CHILD_STATUS.exitstatus,
        output: e.message
      }
    end
  end

  def mysql_config_editor_cmd(context, uid, *args)
    args.unshift('/usr/bin/mysql_config_editor')
    homedir = get_homedir(context, uid)
    Puppet::Util::Execution.execute(
      args,
      failonfail: true,
      uid: uid,
      custom_environment: { 'HOME' => homedir },
    )
  end

  def my_print_defaults_cmd(context, uid, *args)
    args.unshift('/usr/bin/my_print_defaults')
    homedir = get_homedir(context, uid)
    Puppet::Util::Execution.execute(
      args,
      failonfail: true,
      uid: uid,
      custom_environment: { 'HOME' => homedir },
    )
  end

  def get_password(context, uid, name)
    result = ''
    output = my_print_defaults_cmd(context, uid, '-s', name)
    output.split("\n").each do |line|
      result = line.sub(%r{--password=}, '') if line.include?('--password')
    end
    result
  end

  def save_login_path(context, name, should)
    uid = name.fetch(:owner)

    args = ['set', '--skip-warn']
    args.push('-G', should[:name].to_s) if should[:name]
    args.push('-h', should[:host].to_s) if should[:host]
    args.push('-u', should[:user].to_s) if should[:user]
    args.push('-S', should[:socket].to_s) if should[:socket]
    args.push('-P', should[:port].to_s) if should[:port]
    args.push('-p') if should[:password] && extract_pw(should[:password])
    password = (should[:password] && extract_pw(should[:password])) ? extract_pw(should[:password]) : nil

    mysql_config_editor_set_cmd(context, uid, password, args)
  end

  def delete_login_path(context, name)
    login_path = name.fetch(:name)
    uid = name.fetch(:owner)
    mysql_config_editor_cmd(context, uid, 'remove', '-G', login_path)
  end

  def gen_pw(password)
    Puppet::Provider::MysqlLoginPath::Sensitive.new(password)
  end

  def extract_pw(sensitive)
    sensitive.unwrap
  end

  def list_login_paths(context, uid)
    result = []
    output = mysql_config_editor_cmd(context, uid, 'print', '--all')
    ini = Puppet::Provider::MysqlLoginPath::IniFile.new(content: output)
    ini.each_section do |section|
      result.push(ensure: 'present',
                  name: section,
                  owner: uid.to_s,
                  title: "#{section}-#{uid}",
                  host: ini[section]['host'].nil? ? nil : ini[section]['host'],
                  user: ini[section]['user'].nil? ? nil : ini[section]['user'],
                  password: ini[section]['password'].nil? ? nil : gen_pw(get_password(context, uid, section)),
                  socket: ini[section]['socket'].nil? ? nil : ini[section]['socket'],
                  port: ini[section]['port'].nil? ? nil : ini[section]['port'])
    end
    result
  end

  def get(context, name)
    result = []
    owner = name.empty? ? ['root'] : name.filter_map { |item| item[:owner] }.uniq
    owner.each do |uid|
      login_paths = list_login_paths(context, uid)
      result += login_paths
    end
    result
  end

  def create(context, name, should)
    save_login_path(context, name, should)
  end

  def update(context, name, should)
    delete_login_path(context, name)
    save_login_path(context, name, should)
  end

  def delete(context, name)
    delete_login_path(context, name)
  end

  def canonicalize(_context, resources)
    resources.each do |r|
      r[:password] = gen_pw(extract_pw(r[:password])) if r.key?(:password) && r[:password].is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive)
    end
  end
end
