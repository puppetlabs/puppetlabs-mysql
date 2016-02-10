require 'spec_helper'

describe 'mysql::user', :type => :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) {
        facts.merge({
          :root_home => '/root',
        })
      }

      let(:title) { 'testuser' }

      let(:params) {
        { 'password' => 'testpass',
        }
      }

      it 'should report an error when ensure is not present or absent' do
        params.merge!({'ensure' => 'invalid_val'})
        expect { catalogue }.to raise_error(Puppet::Error,
                                          /invalid_val is not supported for ensure\. Allowed values are 'present' and 'absent'\./)
      end

      it 'should not create database user' do
        params.merge!({'ensure' => 'absent', 'host' => 'localhost'})
        is_expected.to contain_mysql_user('testuser@localhost').with_ensure('absent')
      end

      it 'should use user parameter as user name instead of name' do
        params.merge!({'user' => 'realuser'})
        is_expected.to contain_mysql_user('realuser')
      end
    end
  end
end
