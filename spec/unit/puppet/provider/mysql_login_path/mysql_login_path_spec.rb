# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::MysqlLoginPath')
require 'puppet/provider/mysql_login_path/mysql_login_path'

RSpec.describe Puppet::Provider::MysqlLoginPath::MysqlLoginPath do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  before :each do
    allow(provider).to receive(:get_homedir).with(context, 'root').and_return('/root')
    allow(provider).to receive(:mysql_config_editor_cmd).with(context, 'root', 'print', '--all').and_return(
        "[local_tcp]\nuser = root\npassword = *****\nhost = 127.0.0.1\nport = 3306"
    )
    allow(provider).to receive(:mysql_config_editor_cmd).with(
        context, 'root', 'remove', '-G', 'local_socket'
    ).and_return('')
    allow(provider).to receive(:my_print_defaults_cmd).with(
        context, 'root', '-s', 'local_tcp'
    ).and_return("--user=root\n--password=secure\n--host=127.0.0.1\n--port=3306")
    allow(provider).to receive(:my_print_defaults_cmd).with(
        context, 'root', '-s', 'local_socket'
    ).and_return("--user=root\n--password=more_secure\n--host=localhost\n--socket=/var/run/mysql.sock")
    allow(provider).to receive(:mysql_config_editor_set_cmd).with(
        context, 'root', 'more_secure',
        %w(set --skip-warn -G local_socket -h localhost -u root -S /var/run/mysql/mysql.sock -p)
    ).and_return('')
    allow(provider).to receive(:mysql_config_editor_set_cmd).with(
        context, 'root', 'more_secure',
        %w(set --skip-warn -G local_socket -h 127.0.0.1 -u root -P 3306 -p)
    ).and_return('')

    allow(provider).to receive(:gen_pw).with('secure').and_return('Sensitive [value redacted]')
    allow(provider).to receive(:extract_pw).and_return('more_secure')



  end

  describe '#get' do
    it 'processes resources' do
      expect(provider.get(context, [{:owner => 'root'}])).to eq [
        {
            :ensure=>"present",
            :host=>"127.0.0.1",
            :name=>"local_tcp",
            :owner=>"root",
            :password=>"Sensitive [value redacted]",
            :port=>3306,
            :socket=>nil,
            :title=>"local_tcp-root",
            :user=>"root"
        }
      ]
    end
  end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      provider.create(context, {:name =>'local_socket', :owner => 'root'},
                      name: 'local_socket',
                      owner: 'root',
                      host: 'localhost',
                      user: 'root',
                      password: 'more_secure',
                      socket: '/var/run/mysql/mysql.sock',
                      ensure: 'present'
      )
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      provider.update(context, {:name =>'local_socket', :owner => 'root'},
                      name: 'local_socket',
                      owner: 'root',
                      host: '127.0.0.1',
                      user: 'root',
                      password: 'more_secure',
                      port: 3306,
                      ensure: 'present'
      )
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      provider.delete(context, {:name =>'local_socket', :owner => 'root'})
    end
  end

end


