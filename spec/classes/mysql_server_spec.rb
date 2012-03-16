require 'spec_helper'

describe 'mysql::server' do
  let (:facts) do
    { :osfamily => 'Debian' }
  end

  it { should contain_package('mysql-server').with_ensure('present') }
  it do should contain_service('mysqld').with(
    'name'   => 'mysql',
    'ensure' => 'running',
    'enable' => 'true'
  ) end

  it { should contain_class 'mysql::config' }
  it do should contain_exec('mysqld-restart').with(
    'command'     => 'service mysql restart',
    'logoutput'   => 'on_failure',
    'path'        => '/sbin/:/usr/sbin/:/usr/bin/:/bin/',
    'refreshonly' => 'true'
  ) end
end
