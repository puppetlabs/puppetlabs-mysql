require 'spec_helper'

describe 'mysql::db', :type => :define do
  let(:title) { 'test_db' }

  let(:params) {
    { 'user'     => 'testuser',
      'password' => 'testpass',
      'host'     => 'fake_host',
    }
  }

  it 'should not notify the import sql exec if no sql script was provided' do
    should contain_database('test_db').without_notify
  end

  it 'should notify exec to import sql if sql script is given' do
    params.merge!({'sql' => 'test_sql'})
    should contain_database('test_db').with_notify('Exec[test_db-import-import]')
  end

  it 'should assign the user to the database' do
    should contain_database_user('testuser@fake_host/test_db')
  end

  it 'should only import sql script on creation if not enforcing' do
    params.merge!({'sql' => 'test_sql', 'enforce_sql' => false})
    should contain_exec('test_db-import-import').with_refreshonly(true)
  end

  it 'should import sql script on creation if enforcing' do
    params.merge!({'sql' => 'test_sql', 'enforce_sql' => true})
    should contain_exec('test_db-import-import').with_refreshonly(false)
  end
end

describe 'mysql::db', :type => :define do
  let(:title) { 'test_db_2' }

  let(:params) {
    { 'user'     => 'testuser',
      'password' => 'testpass',
      'host'     => 'fake_host',
    }
  }

  it 'should allow for two resource with the same user' do
    should contain_database_user('testuser@fake_host/test_db_2')
  end
end
