require 'spec_helper'

describe 'mysql::config' do
  let(:params) {
    { :root_password => 'password' }
  }

  it { should contain_class 'mysql::config' }

  it 'should have File[/root/.my.cnf] with mode 0400 and owner/group root' do
    should contain_file('/root/.my.cnf').with_mode('0400')
    should contain_file('/root/.my.cnf').with_owner('root')
    should contain_file('/root/.my.cnf').with_group('root')
  end

  it 'should create the mysql_set_pass script with mode 0700 and owner/group root' do
    should contain_file('/var/lib/mysql/mysql_set_pass').with_mode('0700')
    should contain_file('/root/.my.cnf').with_owner('root')
    should contain_file('/root/.my.cnf').with_group('root')
  end
end
