# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::db', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(root_home: '/root')
      end

      let(:title) { 'test_db' }

      let(:params) do
        { 'user'            => 'testuser',
          'password'        => 'testpass',
          'mysql_exec_path' => '' }
      end

      let(:sql) { [ '/tmp/test.sql' ] }

      it 'does not notify the import sql exec if no sql script was provided' do
        is_expected.to contain_mysql_database('test_db').without_notify
      end

      it 'subscribes to database if sql script is given' do
        params['sql'] = sql
        is_expected.to contain_mysql_database('test_db')
        is_expected.to contain_exec('test_db-import').with_subscribe('Mysql_database[test_db]')
      end

      it 'onlies import sql script on creation if not enforcing' do
        params.merge!('sql' => sql, 'enforce_sql' => false)
        is_expected.to contain_exec('test_db-import').with_refreshonly(true)
      end

      it 'imports sql script on creation' do
        params.merge!('sql' => sql, 'enforce_sql' => true)
        # ' if enforcing #refreshonly'
        is_expected.to contain_exec('test_db-import').with_refreshonly(false)
        # 'if enforcing #command'
        is_expected.to contain_exec('test_db-import').with_command('cat /tmp/test.sql | mysql test_db')
      end

      it 'imports sql script with custom command on creation' do
        params.merge!('sql' => sql, 'enforce_sql' => true, 'import_cat_cmd' => 'zcat')
        # if enforcing #refreshonly
        is_expected.to contain_exec('test_db-import').with_refreshonly(false)
        # if enforcing #command
        is_expected.to contain_exec('test_db-import').with_command('zcat /tmp/test.sql | mysql test_db')
      end

      it 'imports sql scripts when more than one is specified' do
        params['sql'] = ['/tmp/test.sql', '/tmp/test_2.sql']
        is_expected.to contain_exec('test_db-import').with_command('cat /tmp/test.sql /tmp/test_2.sql | mysql test_db')
      end

      it 'does not create database' do
        params.merge!('ensure' => 'absent', 'host' => 'localhost')
        is_expected.to contain_mysql_database('test_db').with_ensure('absent')
        is_expected.to contain_mysql_user('testuser@localhost').with_ensure('absent')
      end

      it 'creates with an appropriate collate and charset' do
        params.merge!('charset' => 'utf8', 'collate' => 'utf8_danish_ci')
        is_expected.to contain_mysql_database('test_db').with('charset' => 'utf8',
                                                              'collate' => 'utf8_danish_ci')
      end

      it 'uses dbname parameter as database name instead of name' do
        params['dbname'] = 'real_db'
        is_expected.to contain_mysql_database('real_db')
      end

      it 'uses tls_options for user when set' do
        params['tls_options'] = ['SSL']
        is_expected.to contain_mysql_user('testuser@localhost').with_tls_options(['SSL'])
      end

      it 'uses grant_options for grant when set' do
        params['grant_options'] = ['GRANT']
        is_expected.to contain_mysql_grant('testuser@localhost/test_db.*').with_options(['GRANT'])
      end

      # Invalid file paths
      [
        '|| ls -la ||',
        '|| touch /tmp/foo.txt ||',
        '/tmp/foo.txt;echo',
        'myPath;',
        '\\myPath\\',
        '//myPath has spaces//',
        '/',
      ].each do |path|
        it "fails when provided '#{path}' as a value to the 'sql' parameter" do
          params['sql'] = [path]
          is_expected.to raise_error(Puppet::PreformattedError, %r{The file '#{Regexp.escape(path)}' is invalid. A valid file path is expected.})
        end
      end

      # Valid file paths
      [
        '/tmp/test.txt',
        '/tmp/.test',
        '/foo.test',
        '/foo.test.txt',
        '/foo/test/test-1.2.3/schema/test.sql',
        '/foo/test/test-1.2.3/schema/foo.test.sql',
        '/foo/foo.t1.t2.t3/foo.test-1.2.3/test.test.schema/test..app.sql',
        '/foo/foo.t1.t2...t3/foo.test-1.2.3/test.test.schema/test.app.sql',
      ].each do |path|
        it "succeeds when provided '#{path}' as a value to the 'sql' parameter" do
          params['sql'] = [path]
          is_expected.to contain_exec('test_db-import').with_command("cat #{path} | mysql test_db")
        end
      end

      # Invalid database names
      [
        'test db',
        'test_db;',
        'test/db',
        '|| ls -la ||',
        '|| touch /tmp/foo.txt ||',
      ].each do |name|
        it "fails when provided '#{name}' as a value to the 'name' parameter" do
          params['name'] = name
          is_expected.to raise_error(Puppet::PreformattedError, %r{The database name '#{name}' is invalid.})
        end
      end

      # Valid database names
      [
        'test_db',
        'testdb',
        'test-db',
        'TESTDB',
      ].each do |name|
        it "succeeds when the provided '#{name}' as a value to the 'dbname' parameter" do
          params['dbname'] = name
          is_expected.to contain_mysql_database(name)
        end
      end
    end
  end
end
