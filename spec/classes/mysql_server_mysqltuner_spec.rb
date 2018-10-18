require 'spec_helper'

describe 'mysql::server::mysqltuner' do
  context 'ensure => present' do
    it { is_expected.to compile }
    it {
      is_expected.to contain_file('/usr/local/bin/mysqltuner')
    }
  end

  context 'ensure => absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to compile }
    it { is_expected.to contain_file('/usr/local/bin/mysqltuner').with(ensure: 'absent') }
  end

  context 'custom version' do
    let(:params) { { version: 'v1.2.0' } }

    it { is_expected.to compile }
    it {
      is_expected.to contain_file('/usr/local/bin/mysqltuner')
    }
  end

  context 'custom source' do
    let(:params) { { source: '/tmp/foo' } }

    it { is_expected.to compile }
    it {
      is_expected.to contain_file('/usr/local/bin/mysqltuner')
    }
  end
end
