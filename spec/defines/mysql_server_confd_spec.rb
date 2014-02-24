require 'spec_helper'

describe 'mysql::server::confd', :type => :define do
  let(:facts) {{ :osfamily => 'RedHat' }}
  let(:title) { 'server_id' }
  let(:file_path) { '/etc/mysql/conf.d/server_id.cnf' }
  
  describe '#content' do
    let(:params) {{
      :content => "[mysqld]\nserver_id = 123\n",
    }}

    it 'should create file with content' do
      should contain_file(file_path).with({
        :ensure  => 'file',
        :source  => nil,
        :require => 'Class[Mysql::Server::Config]',
        :content => <<EOS
[mysqld]
server_id = 123
EOS
      })
    end
  end

  describe '#source' do
    let(:params) {{
      :source => 'puppet:///foo/bar',
    }}

    it 'should create file with source' do
      should contain_file(file_path).with({
        :ensure  => 'file',
        :content => nil,
        :source  => 'puppet:///foo/bar',
        :require => 'Class[Mysql::Server::Config]',
      })
    end
  end

  describe 'restart service' do
    describe 'false' do
      let(:pre_condition) { <<-EOS
        class { 'mysql::server':
          restart => false,
        }
        EOS
      }

      it 'should not notify service' do
        should_not contain_file(file_path).that_notifies('Class[mysql::server::service]')
      end
    end

    describe 'true' do
      let(:pre_condition) { <<-EOS
        class { 'mysql::server':
          restart => true,
        }
        EOS
      }

      it 'should notify service' do
        should contain_file(file_path).that_notifies('Class[mysql::server::service]')
      end
    end
  end
end
