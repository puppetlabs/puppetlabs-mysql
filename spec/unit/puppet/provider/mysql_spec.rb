# frozen_string_literal: true

require 'spec_helper'
require 'puppet/provider/mysql'

describe Puppet::Provider::Mysql do
  mariadb_string = '/usr/sbin/mariadbd from 11.4.2-MariaDB (mariadbd 11.4.2-MariaDB-ubu2404)'
  mysql_string = '/usr/sbin/mysqld  Ver 8.0.36 for Linux on x86_64 (MySQL Community Server - GPL)'
  warning = "/usr/bin/mysql: Deprecated program name. It will be removed in a future release, use '/usr/bin/mariadb' instead\n"

  let(:commands) { described_class::COMMANDS }
  # Fresh subclass per example so the per-class memoisation does not leak between examples.
  let(:klass) do
    commands = self.commands
    Class.new(described_class) do
      initvars
      commands.each do |key, binaries|
        binaries.each_with_index { |binary, idx| optional_commands "#{key}#{idx}": binary }
      end
    end
  end
  let(:installed) { commands.values.flatten }
  let(:version_string) { mariadb_string }

  before :each do
    stub_const('Puppet::Provider::Mysql::COMMANDS', commands)
    klass.instance_variable_set(:@mysql_commands, nil)
    klass.instance_variable_set(:@mysqld_version_string, nil)
    allow(Facter).to receive(:value).with(:root_home).and_return('/root')
    allow(Facter).to receive(:value).with(:mysqld_version).and_return(version_string)
    allow(klass).to receive(:which) { |binary| installed.include?(binary) ? "/usr/bin/#{binary}" : nil }
    commands.each do |key, binaries|
      binaries.each_index { |idx| allow(klass).to receive(:"#{key}#{idx}").and_return("#{key}#{idx}") }
    end
  end

  describe 'command selection' do
    # [binaries, server version string, installed binary indexes, expected candidate index]
    scenarios = [
      [['mysql', 'mariadb'], mariadb_string, [0, 1], 1],
      [['mysql', 'mariadb'], mysql_string, [0, 1], 0],
      [['mysql', 'mariadb'], mariadb_string, [0], 0],
      [['mysql', 'mariadb'], mariadb_string, [1], 1],
      [['mariadb', 'mysql'], mariadb_string, [0, 1], 0],
      [['mariadb', 'mysql'], mysql_string, [0, 1], 0],
      [['mysql', 'mariadb', 'mysql-other'], mariadb_string, [0, 1, 2], 1],
      [['mysql', 'mariadb', 'mysql-other'], mariadb_string, [0, 2], 0],
      [['mysql-a', 'mariadb-a', 'mysql-b', 'mariadb-b'], mariadb_string, [0, 2, 3], 3],
      [['mysql-a', 'mariadb-a', 'mysql-b', 'mariadb-b'], mariadb_string, [0, 2], 0],
    ]

    scenarios.each do |binaries, version, installed_idx, expected_idx|
      context "with #{binaries.inspect} on #{(version == mariadb_string) ? 'MariaDB' : 'MySQL'} and #{installed_idx.inspect} installed" do
        let(:commands) { { mysql_raw: binaries }.freeze }
        let(:version_string) { version }
        let(:installed) { installed_idx.map { |idx| binaries[idx] } }

        it "selects candidate #{expected_idx}" do
          expect(klass.mysql_raw(['x'])).to eq("mysql_raw#{expected_idx}")
        end
      end
    end

    [:mysqld, :mysqladmin].each do |key|
      it "prefers the mariadb name for #{key} on MariaDB" do
        expect(klass.send(key, ['x'])).to eq("#{key}1")
      end
    end

    { 'raises' => -> { raise Errno::ENOENT }, 'returns nil' => -> {} }.each do |description, detection|
      it "keeps the default order when server type detection #{description}" do
        allow(Facter).to receive(:value).with(:mysqld_version).and_return(nil)
        allow(klass).to receive(:version_raw) { detection.call }
        expect(klass.mysql_raw(['x'])).to eq('mysql_raw0')
      end
    end
  end

  describe 'self.strip_deprecation_warnings' do
    crafted = "root@localhost\nx: Deprecated program name. It will be removed in a future release, use '@%\nbackdoor@%\nz@' instead\nother@localhost\n"
    other = "/usr/bin/mysqladmin: Deprecated program name. It will be removed in a future release, use '/usr/bin/mariadb-admin' instead\n"

    # [description, input, expected output]
    scenarios = [
      ['removes a leading warning', "#{warning}3\n", "3\n"],
      ['removes a leading warning from a tab separated row', "#{warning}3\t10\t\t*6C89\n", "3\t10\t\t*6C89\n"],
      ['removes stacked leading warnings', "#{warning}#{other}3\n", "3\n"],
      ['leaves output without the warning unchanged', "3\t10\n", "3\t10\n"],
      ['leaves a row containing the word Deprecated unchanged', "my_plugin\tDeprecated program name. It will be removed\n", "my_plugin\tDeprecated program name. It will be removed\n"],
      ['does not let a crafted multi-row account name hide real rows', crafted, crafted],
      ['does not strip a warning-looking line in the middle of the output', "root@localhost\n#{warning}", "root@localhost\n#{warning}"],
    ]

    # A warning is logged once per stripped output, and nothing is logged when the output is unchanged.
    scenarios.each do |description, input, expected|
      it description do
        logged = []
        allow(klass).to receive(:warnonce) { |message| logged << message }
        expect(klass.strip_deprecation_warnings(input)).to eq(expected)
        expect(logged).to match((input == expected) ? [] : [a_string_including('Deprecated program name')])
      end
    end
  end

  describe 'self.mysql_caller' do
    before :each do
      allow(File).to receive(:file?).with('/root/.mylogin.cnf').and_return(false)
      allow(File).to receive(:file?).with('/root/.my.cnf').and_return(false)
      allow(klass).to receive(:warnonce)
    end

    ['system', 'regular'].each do |type|
      it "strips the deprecation warning for type #{type}" do
        allow(klass).to receive(:mysql_raw).and_return("#{warning}3\n")
        expect(klass.mysql_caller('SELECT 3', type)).to eq("3\n")
      end
    end

    it 'strips the warning when invalid bytes are scrubbed' do
      allow(klass).to receive(:mysql_raw).and_return(("#{warning}caf".b << 0xE9 << 0x0A).force_encoding('UTF-8'))
      expect(klass.mysql_caller('SELECT 3', 'regular')).to eq("caf\u{FFFD}\n")
    end
  end
end
