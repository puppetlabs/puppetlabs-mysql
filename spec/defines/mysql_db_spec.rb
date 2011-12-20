require 'spec_helper'

describe 'mysql::db', :type => :define do
  let(:title) { 'test_db' }
  let(:params) {
    {'user'        => 'testuser',
     'password'    => 'testpass',
     'enforce_sql' => false,
     'sql'         => 'test_sql',
    }
  }

  it 'should set load of sql script to refreshonly' do
    should create_resource('exec', 'test_db-import-import').with_param('refreshonly', true)
  end
end
