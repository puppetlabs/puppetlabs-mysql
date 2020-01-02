require 'spec_helper'

describe 'mysql::backup::mysqldump' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) do
        <<-EOF
          class { 'mysql::server': }
        EOF
      end
      let(:facts) do
        facts.merge(root_home: '/root')
      end

      let(:default_params) do
        { 'backupuser'         => 'testuser',
          'backuppassword'     => 'testpass',
          'backupdir'          => '/tmp/mysql-backup',
          'backuprotate'       => '25',
          'delete_before_dump' => true,
          'execpath'           => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
          'maxallowedpacket'   => '1M' }
      end

      context 'with time included' do
        let(:params) do
          { time: [23, 59, 30, 12, 6] }.merge(default_params)
        end

        it {
          is_expected.to contain_cron('mysql-backup').with(
            hour: 23,
            minute: 59,
            monthday: 30,
            month: 12,
            weekday: 6,
          )
        }
      end

      context 'with defaults' do
        let(:params) { default_params }

        it {
          is_expected.to contain_cron('mysql-backup').with(
            command: '/usr/local/sbin/mysqlbackup.sh',
            ensure: 'present',
            hour: 23,
            minute: 5,
          )
        }
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups
end
