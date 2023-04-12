# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::MysqlLoginPath')
require 'puppet/provider/mysql_login_path/mysql_login_path'

RSpec.describe Puppet::Provider::MysqlLoginPath::MysqlLoginPath do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext') }
  let(:wait_thr) { instance_double('wait_thr') }
  let(:wait_thr_value) { instance_double('wait_thr_value') }
  let(:sensitive_secure) { Puppet::Provider::MysqlLoginPath::Sensitive.new('secure') }
  let(:sensitive_more_secure) { Puppet::Provider::MysqlLoginPath::Sensitive.new('more_secure') }

  before :each do
    # Puppet::Util::Execution.stubs(:execute).with(['/usr/bin/getent', 'passwd', 'root'], failonfail: true).returns('root:x:0:0:root:/root:/bin/bash')
    allow(Puppet::Util::Execution).to receive(:execute).with(['/usr/bin/getent', 'passwd', 'root'], failonfail: true).and_return('root:x:0:0:root:/root:/bin/bash')
    allow(Puppet::Util::Execution).to receive(:execute).with(['/usr/bin/mysql_config_editor', 'print', '--all'], failonfail: true, uid: 'root', custom_environment: { 'HOME' => '/root' })
                                                       .and_return("[local_tcp]\nuser = root\npassword = *****\nhost = 127.0.0.1\nport = 3306")
    allow(Puppet::Util::Execution).to receive(:execute).with(['/usr/bin/mysql_config_editor', 'remove', '-G', 'local_socket'], failonfail: true, uid: 'root', custom_environment: { 'HOME' => '/root' })
    allow(Puppet::Util::Execution).to receive(:execute).with(['/usr/bin/my_print_defaults', '-s', 'local_tcp'], failonfail: true, uid: 'root', custom_environment: { 'HOME' => '/root' })
                                                       .and_return("--user=root\n--password=secure\n--host=127.0.0.1\n--port=3306")
    allow(Puppet::Util::Execution).to receive(:execute).with(['/usr/bin/my_print_defaults', '-s', 'local_socket'], failonfail: true, uid: 'root', custom_environment: { 'HOME' => '/root' })
                                                       .and_return("--user=root\n--password=more_secure\n--host=localhost\n--socket=/var/run/mysql.sock")

    allow(Puppet::Util::SUIDManager).to receive(:asuser).with('root').and_return(`(exit 0)`)
    allow(PTY).to receive(:spawn)
      .with({ 'HOME' => '/root' },
            '/usr/bin/mysql_config_editor set --skip-warn -G local_socket -h localhost -u root ' \
            '-S /var/run/mysql/mysql.sock -p')
      .and_return(`(exit 0)`)

    allow(PTY).to receive(:spawn)
      .with({ 'HOME' => '/root' },
            '/usr/bin/mysql_config_editor set --skip-warn -G local_socket -h 127.0.0.1 -u root -P 3306 -p')
      .and_return(`(exit 0)`)
  end

  describe '#get' do
    it 'processes resources' do
      expect(provider.get(context, [{ owner: 'root' }])).to eq [
        {
          ensure: 'present',
          host: '127.0.0.1',
          name: 'local_tcp',
          owner: 'root',
          password: sensitive_secure,
          port: 3306,
          socket: nil,
          title: 'local_tcp-root',
          user: 'root'
        },
      ]
    end
  end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      provider.create(context, { name: 'local_socket', owner: 'root' },
                      name: 'local_socket',
                      owner: 'root',
                      host: 'localhost',
                      user: 'root',
                      password: sensitive_more_secure,
                      socket: '/var/run/mysql/mysql.sock',
                      ensure: 'present')
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      provider.update(context, { name: 'local_socket', owner: 'root' },
                      name: 'local_socket',
                      owner: 'root',
                      host: '127.0.0.1',
                      user: 'root',
                      password: sensitive_more_secure,
                      port: 3306,
                      ensure: 'present')
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      provider.delete(context, name: 'local_socket', owner: 'root')
    end
  end
end
