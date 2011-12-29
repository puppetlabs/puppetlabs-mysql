require 'spec_helper'

describe 'mysql::ruby' do

  let(:facts) { {:operatingsystem => 'Unknown'} }

  it do
    should contain_class 'mysql::ruby'
  end

  it 'should manage the ruby-mysql package with yum on redhat' do
    facts.merge!({ :operatingsystem => 'RedHat' })
    should contain_package('ruby-mysql').with_name('ruby-mysql')
    should contain_package('ruby-mysql').with_provider('yum')
  end

  it 'should manage the libmysql-ruby package with apt on debian' do
    facts.merge!({:operatingsystem => 'Debian' })
    should contain_package('ruby-mysql').with_name('libmysql-ruby')
    should contain_package('ruby-mysql').with_provider('apt')
  end

  it 'should manage the mysql package with gem on everything else' do
    should contain_package('ruby-mysql').with_name('mysql')
    should contain_package('ruby-mysql').with_provider('gem')
  end
end
