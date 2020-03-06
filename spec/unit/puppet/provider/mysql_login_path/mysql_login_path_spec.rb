# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::MysqlLoginPath')
require 'puppet/provider/mysql_login_path/mysql_login_path'

RSpec.describe Puppet::Provider::MysqlLoginPath::MysqlLoginPath do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  describe '#get' do
    it 'processes resources' do
      expect(context).to receive(:debug).with('Returning pre-canned example data')
      expect(provider.get(context)).to eq [
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
  end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      expect(context).to receive(:notice).with(%r{\ACreating 'local'})

      provider.create(context, 'local',
                      name: 'local',
                      host: 'localhost',
                      user: 'root',
                      password: 'secure',
                      socket: '/var/run/mysql/mysql.sock',
                      ensure: 'present'
      )
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'local'})

      provider.update(context, 'local',
                      name: 'local',
                      host: '127.0.0.1',
                      user: 'root',
                      password: 'secure',
                      port: 3306,
                      ensure: 'present'
      )
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      expect(context).to receive(:notice).with(%r{\ADeleting 'local'})

      provider.delete(context, 'local')
    end
  end
end
