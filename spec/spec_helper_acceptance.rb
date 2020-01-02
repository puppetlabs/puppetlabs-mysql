# frozen_string_literal: true

require 'serverspec'
require 'puppet_litmus'
require 'spec_helper_acceptance_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_acceptance_local.rb'))
include PuppetLitmus

if ENV['TARGET_HOST'].nil? || ENV['TARGET_HOST'] == 'localhost'
  puts 'Running tests against this machine !'
  if Gem.win_platform?
    set :backend, :cmd
  else
    set :backend, :exec
  end
else
  # load inventory
  inventory_hash = inventory_hash_from_inventory_file
  node_config = config_from_node(inventory_hash, ENV['TARGET_HOST'])

  if target_in_group(inventory_hash, ENV['TARGET_HOST'], 'docker_nodes')
    host = ENV['TARGET_HOST']
    set :backend, :docker
    set :docker_container, host
  elsif target_in_group(inventory_hash, ENV['TARGET_HOST'], 'ssh_nodes')
    set :backend, :ssh
    options = Net::SSH::Config.for(host)
    options[:user] = node_config.dig('ssh', 'user') unless node_config.dig('ssh', 'user').nil?
    options[:port] = node_config.dig('ssh', 'port') unless node_config.dig('ssh', 'port').nil?
    options[:keys] = node_config.dig('ssh', 'private-key') unless node_config.dig('ssh', 'private-key').nil?
    options[:password] = node_config.dig('ssh', 'password') unless node_config.dig('ssh', 'password').nil?
    # Support both net-ssh 4 and 5.
    # rubocop:disable Metrics/BlockNesting
    options[:verify_host_key] = if node_config.dig('ssh', 'host-key-check').nil?
                                  # Fall back to SSH behavior. This variable will only be set in net-ssh 5.3+.
                                  if @strict_host_key_checking.nil? || @strict_host_key_checking
                                    Net::SSH::Verifiers::Always.new
                                  else
                                    # SSH's behavior with StrictHostKeyChecking=no: adds new keys to known_hosts.
                                    # If known_hosts points to /dev/null, then equivalent to :never where it
                                    # accepts any key beacuse they're all new.
                                    Net::SSH::Verifiers::AcceptNewOrLocalTunnel.new
                                  end
                                elsif node_config.dig('ssh', 'host-key-check')
                                  if defined?(Net::SSH::Verifiers::Always)
                                    Net::SSH::Verifiers::Always.new
                                  else
                                    Net::SSH::Verifiers::Secure.new
                                  end
                                elsif defined?(Net::SSH::Verifiers::Never)
                                  Net::SSH::Verifiers::Never.new
                                else
                                  Net::SSH::Verifiers::Null.new
                                end
    # rubocop:enable Metrics/BlockNesting
    host = if ENV['TARGET_HOST'].include?(':')
             ENV['TARGET_HOST'].split(':').first
           else
             ENV['TARGET_HOST']
           end
    set :host,        options[:host_name] || host
    set :ssh_options, options
    set :request_pty, true
  elsif target_in_group(inventory_hash, ENV['TARGET_HOST'], 'winrm_nodes')
    require 'winrm'

    set :backend, :winrm
    set :os, family: 'windows'
    user = node_config.dig('winrm', 'user') unless node_config.dig('winrm', 'user').nil?
    pass = node_config.dig('winrm', 'password') unless node_config.dig('winrm', 'password').nil?
    endpoint = "http://#{ENV['TARGET_HOST']}:5985/wsman"

    opts = {
      user: user,
      password: pass,
      endpoint: endpoint,
      operation_timeout: 300,
    }

    winrm = WinRM::Connection.new opts
    Specinfra.configuration.winrm = winrm
  end
end
