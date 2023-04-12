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
      databases = provider.class.instances.map { |x| x.name }
      expect(parsed_databases).to match_array(databases)
    end
  end

  describe 'self.prefetch' do
    it 'exists' do
      provider.class.instances
      provider.class.prefetch({})
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
