# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:mysql_plugin).provider(:mysql) do
  let(:defaults_file) { '--defaults-extra-file=/root/.my.cnf' }
  let(:provider) { resource.provider }
  let(:instance) { provider.class.instances.first }
  let(:resource) do
    Puppet::Type.type(:mysql_plugin).new(
      ensure: :present,
      soname: 'auth_socket.so',
      name: 'auth_socket',
      provider: described_class.name,
    )
  end

  before :each do
    allow(Facter).to receive(:value).with(:root_home).and_return('/root')
    allow(Puppet::Util).to receive(:which).with('mysql').and_return('/usr/bin/mysql')
    allow(File).to receive(:file?).with('/root/.my.cnf').and_return(true)
    allow(provider.class).to receive(:mysql_caller).with('show plugins', 'regular').and_return('auth_socket	ACTIVE	AUTHENTICATION	auth_socket.so	GPL')
  end

  describe 'self.prefetch' do
    it 'exists' do
      provider.class.instances
      provider.class.prefetch({})
    end
  end

  describe 'create' do
    it 'loads a plugin' do
      expect(provider.class).to receive(:mysql_caller).with("install plugin #{resource[:name]} soname '#{resource[:soname]}'", 'regular')
      expect(provider).to receive(:exists?).and_return(true)
      expect(provider.create).to be_truthy
    end
  end

  describe 'destroy' do
    it 'unloads a plugin if present' do
      expect(provider.class).to receive(:mysql_caller).with("uninstall plugin #{resource[:name]}", 'regular')
      expect(provider).to receive(:exists?).and_return(false)
      expect(provider.destroy).to be_truthy
    end
  end

  describe 'exists?' do
    it 'checks if plugin exists' do
      expect(instance).to be_exists
    end
  end

  describe 'self.defaults_file' do
    it 'sets --defaults-extra-file' do
      allow(File).to receive(:file?).with('/root/.my.cnf').and_return(true)
      expect(provider.defaults_file).to eq '--defaults-extra-file=/root/.my.cnf'
    end
    it 'fails if file missing' do
      allow(File).to receive(:file?).with('/root/.my.cnf').and_return(false)
      expect(provider.defaults_file).to be_nil
    end
  end

  describe 'soname' do
    it 'returns a soname' do
      expect(instance.soname).to eq('auth_socket.so')
    end
  end
end
