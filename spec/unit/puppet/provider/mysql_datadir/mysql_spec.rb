# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:mysql_datadir).provider(:mysql) do
  let(:provider) { resource.provider }
  let(:resource) do
    Puppet::Type.type(:mysql_datadir).new(
      ensure: :present,
      datadir: '/var/lib/mysql',
      basedir: '/usr',
      user: 'mysql',
      log_error: '/var/tmp/mysqld_initialize.log',
      provider: described_class.name,
    )
  end

  before :each do
    allow(Facter).to receive(:value).with(:root_home).and_return('/root')
    allow(Puppet::Util).to receive(:which).with('mysqld').and_return('/usr/sbin/mysqld')
    allow(Puppet::Util).to receive(:which).with('mariadbd').and_return(nil)
  end

  describe 'create' do
    context 'with MySQL >= 5.7.6 (GH-1770 regression)' do
      before :each do
        allow(provider).to receive_messages(mysqld_version: '5.7.6', exists?: true)
        allow(provider).to receive(:newer_than).with('mysql' => '5.7.6', 'percona' => '5.7.6').and_return(true)
      end

      it 'does not raise NoMethodError and dispatches to mysqld via self.class' do
        expect(described_class).to receive(:mysqld).with(
          array_including(
            '--basedir=/usr',
            '--datadir=/var/lib/mysql',
            '--user=mysql',
            '--log-error=/var/tmp/mysqld_initialize.log',
            '--initialize-insecure',
          ),
        )

        expect { provider.create }.not_to raise_error
      end
    end

    context 'with an older MySQL version' do
      before :each do
        allow(provider).to receive_messages(mysqld_version: nil, exists?: true)
      end

      it 'initializes the datadir with mysql_install_db instead of mysqld' do
        expect(provider).to receive(:mysql_install_db).with(
          array_including(
            '--basedir=/usr',
            '--datadir=/var/lib/mysql',
            '--user=mysql',
          ),
        )
        expect(described_class).not_to receive(:mysqld)

        provider.create
      end
    end
  end

  describe 'destroy' do
    it 'raises ArgumentError since the datadir can not be removed' do
      expect { provider.destroy }.to raise_error(ArgumentError)
    end
  end

  describe 'exists?' do
    it 'returns true when the mysql subdirectory is populated' do
      allow(File).to receive(:directory?).with('/var/lib/mysql/mysql').and_return(true)
      allow(Dir).to receive(:entries).with('/var/lib/mysql/mysql').and_return(['.', '..', 'ibdata1'])

      expect(provider).to be_exists
    end

    it 'returns false when the mysql subdirectory does not exist' do
      allow(File).to receive(:directory?).with('/var/lib/mysql/mysql').and_return(false)

      expect(provider).not_to be_exists
    end

    it 'returns false when the mysql subdirectory is empty' do
      allow(File).to receive(:directory?).with('/var/lib/mysql/mysql').and_return(true)
      allow(Dir).to receive(:entries).with('/var/lib/mysql/mysql').and_return(['.', '..'])

      expect(provider).not_to be_exists
    end
  end
end
