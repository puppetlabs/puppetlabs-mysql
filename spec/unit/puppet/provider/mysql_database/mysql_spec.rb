# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:mysql_database).provider(:mysql) do
  let(:defaults_file) { '--defaults-extra-file=/root/.my.cnf' }
  let(:parsed_databases) { ['information_schema', 'mydb', 'mysql', 'performance_schema', 'test'] }
  let(:provider) { resource.provider }
  let(:instance) { provider.class.instances.first }
  let(:resource) do
    Puppet::Type.type(:mysql_database).new(
      ensure: :present, charset: 'latin1',
      collate: 'latin1_swedish_ci', name: 'new_database',
      provider: described_class.name
    )
  end
  let(:raw_databases) do
    <<~SQL_OUTPUT
      information_schema
      mydb
      mysql
      performance_schema
      test
    SQL_OUTPUT
  end

  before :each do
    allow(Facter.fact(:value)).to receive(:root_home).and_return('/root')
    allow(Puppet::Util).to receive(:which).with('mysql').and_return('/usr/bin/mysql')
    allow(File).to receive(:file?).with('/root/.my.cnf').and_return(true)
    allow(provider.class).to receive(:mysql_caller).with('show databases', 'regular').and_return('new_database')
    allow(provider.class).to receive(:mysql_caller).with(["show variables like '%_database'", 'new_database'], 'regular').and_return("character_set_database latin1\ncollation_database latin1_swedish_ci\nskip_show_database OFF") # rubocop:disable Layout/LineLength
  end

  describe 'self.instances' do
    it 'returns an array of databases' do
      allow(provider.class).to receive(:mysql_caller).with('show databases', 'regular').and_return(raw_databases)
      raw_databases.each_line do |db|
        allow(provider.class).to receive(:mysql_caller).with(["show variables like '%_database'", db.chomp], 'regular').and_return("character_set_database latin1\ncollation_database  latin1_swedish_ci\nskip_show_database  OFF") # rubocop:disable Layout/LineLength
      end
      databases = provider.class.instances.map(&:name)
      expect(parsed_databases).to match_array(databases)
    end

    it 'skips managed databases that no longer exist' do
      allow(provider.class).to receive(:mysql_caller).with(["show variables like '%_database'", 'managed_existing'], 'regular').and_return("character_set_database latin1\ncollation_database  latin1_swedish_ci\nskip_show_database  OFF") # rubocop:disable Layout/LineLength
      allow(provider.class).to receive(:mysql_caller).with(["show variables like '%_database'", 'managed_missing'], 'regular').and_raise(Puppet::ExecutionFailure, 'ERROR 1049 (42000): Unknown database')

      databases = provider.class.instances(['managed_existing', 'managed_missing']).map(&:name)
      expect(databases).to eq(['managed_existing'])
    end

    it 're-raises unexpected database lookup failures' do
      allow(provider.class).to receive(:mysql_caller).with(["show variables like '%_database'", 'managed_broken'], 'regular').and_raise(Puppet::ExecutionFailure, 'ERROR 1044 (42000): Access denied')

      expect { provider.class.instances(['managed_broken']) }.to raise_error(Puppet::ExecutionFailure, 'ERROR 1044 (42000): Access denied')
    end

    it 'falls back to full scan when managed database list is empty' do
      allow(provider.class).to receive(:mysql_caller).with('show databases', 'regular').and_return("fallback_db\n")
      allow(provider.class).to receive(:mysql_caller).with(["show variables like '%_database'", 'fallback_db'], 'regular').and_return("character_set_database latin1\ncollation_database latin1_swedish_ci\nskip_show_database OFF") # rubocop:disable Layout/LineLength

      databases = provider.class.instances([]).map(&:name)
      expect(databases).to eq(['fallback_db'])
    end
  end

  describe 'self.prefetch' do
    it 'exists' do
      provider.class.instances
      provider.class.prefetch({})
    end

    it 'only prefetches managed databases from resources' do
      resources = {
        'db_one' => instance_double(Puppet::Type.type(:mysql_database)),
        'db_two' => instance_double(Puppet::Type.type(:mysql_database))
      }

      allow(provider.class).to receive(:instances).with(['db_one', 'db_two']).and_return([])
      resources.values.each { |res| allow(res).to receive(:provider=) }

      provider.class.prefetch(resources)
      expect(provider.class).to have_received(:instances).with(['db_one', 'db_two'])
    end
  end

  describe 'create' do
    it 'makes a database' do
      expect(provider.class).to receive(:mysql_caller).with("create database if not exists `#{resource[:name]}` character set `#{resource[:charset]}` collate `#{resource[:collate]}`", 'regular')
      expect(provider).to receive(:exists?).and_return(true)
      expect(provider.create).to be_truthy
    end
  end

  describe 'destroy' do
    it 'removes a database if present' do
      expect(provider.class).to receive(:mysql_caller).with("drop database if exists `#{resource[:name]}`", 'regular')
      expect(provider).to receive(:exists?).and_return(false)
      expect(provider.destroy).to be_truthy
    end
  end

  describe 'exists?' do
    it 'checks if database exists' do
      expect(instance).to be_exists
    end
  end

  describe 'self.defaults_file' do
    before :each do
      allow(Facter).to receive(:value).with(:root_home).and_return('/root')
    end

    it 'sets --defaults-extra-file' do
      allow(File).to receive(:file?).with('/root/.my.cnf').and_return(true)
      expect(provider.defaults_file).to eq '--defaults-extra-file=/root/.my.cnf'
    end

    it 'fails if file missing' do
      allow(File).to receive(:file?).with('/root/.my.cnf').and_return(false)
      expect(provider.defaults_file).to be_nil
    end
  end

  describe 'charset' do
    it 'returns a charset' do
      expect(instance.charset).to eq('latin1')
    end
  end

  describe 'charset=' do
    it 'changes the charset' do
      expect(provider.class).to receive(:mysql_caller).with("alter database `#{resource[:name]}` CHARACTER SET blah", 'regular').and_return('0')
      provider.charset = 'blah'
    end
  end

  describe 'collate' do
    it 'returns a collate' do
      expect(instance.collate).to eq('latin1_swedish_ci')
    end
  end

  describe 'collate=' do
    it 'changes the collate' do
      expect(provider.class).to receive(:mysql_caller).with("alter database `#{resource[:name]}` COLLATE blah", 'regular').and_return('0')
      provider.collate = 'blah'
    end
  end
end
