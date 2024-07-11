# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::bindings' do
  on_supported_os.each do |os, facts|
    next if facts[:os]['family'] == 'Archlinux'

    context "on #{os}" do
      let(:facts) { facts }
      let(:params) do
        {
          'java_enable' => true,
          'perl_enable' => true,
          'php_enable' => true,
          'python_enable' => true,
          'ruby_enable' => true,
          'client_dev' => true,
          'daemon_dev' => true,
          'client_dev_package_name' => 'libmysqlclient-devel',
          'daemon_dev_package_name' => 'mysql-devel'
        }
      end

      it { is_expected.to contain_class('mysql::params') }

      it { is_expected.to contain_class('mysql::bindings::java') }
      it { is_expected.to contain_package('mysql-connector-java') }

      it { is_expected.to contain_class('mysql::bindings::perl') }
      it { is_expected.to contain_package('perl_mysql') }

      it { is_expected.to contain_class('mysql::bindings::python') }
      it { is_expected.to contain_package('python-mysqldb') }

      it { is_expected.to contain_class('mysql::bindings::ruby') }
      it { is_expected.to contain_package('ruby_mysql') }

      it { is_expected.to contain_class('mysql::bindings::php') }
      it { is_expected.to contain_package('php-mysql') }

      it { is_expected.to contain_class('mysql::bindings::client_dev') }
      it { is_expected.to contain_package('mysql-client_dev') }

      it { is_expected.to contain_class('mysql::bindings::daemon_dev') }
      it { is_expected.to contain_package('mysql-daemon_dev') }
    end
  end
end
