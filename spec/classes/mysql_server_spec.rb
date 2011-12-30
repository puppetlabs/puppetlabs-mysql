require 'spec_helper'

describe 'mysql::server' do
  let(:facts) { {:operatingsystem => 'Unknown' } }
  let(:params) { {} }

  it { should contain_class('mysql::server') }

  it 'should manage the mysql-server package with name mysql-server' do
    should contain_package('mysql-server').with_name('mysql-server')
  end

  it 'should manage the mysql-server package with alternative name if provided' do
    params.merge!({'package_name' => 'fake-mysql-package'})

    should contain_package('mysql-server').with_name('fake-mysql-package')
  end

  it 'should notify mysqld service if Package[mysql-server] changes' do
    should contain_package('mysql-server').with_notify('Service[mysqld]')
  end

  it 'should manage the mysqld service on RedHat' do
    facts.merge!({:operatingsystem => 'RedHat'})

    should contain_service('mysqld').with_name('mysqld')
  end

  it 'should manage the mysql service on Debian' do
    facts.merge!({:operatingsystem => 'Debian'})

    should contain_service('mysqld').with_name('mysql')
  end
end
