require 'spec_helper'
describe 'mysql::server::monitor' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(root_home: '/root')
      end

      let :pre_condition do
        "include 'mysql::server'"
      end

      let :default_params do
        {
          mysql_monitor_username: 'monitoruser',
          mysql_monitor_password: 'monitorpass',
          mysql_monitor_hostname: 'monitorhost',
        }
      end

      let :params do
        default_params
      end

      it { is_expected.to contain_mysql_user('monitoruser@monitorhost') }

      it {
        is_expected.to contain_mysql_grant('monitoruser@monitorhost/*.*').with(
          ensure: 'present', user: 'monitoruser@monitorhost',
          table: '*.*', privileges: %w[PROCESS SUPER],
          require: 'Mysql_user[monitoruser@monitorhost]'
        )
      }
    end
  end
end
