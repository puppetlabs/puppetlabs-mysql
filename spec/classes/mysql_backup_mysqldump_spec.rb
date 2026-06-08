# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::backup::mysqldump' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) do
        <<-MANIFEST
          class { 'mysql::server': }
        MANIFEST
      end
      let(:facts) do
        facts.merge(root_home: '/root')
      end

      let(:default_params) do
        { 'backupuser' => 'testuser',
          'backuppassword' => 'testpass',
          'backupdir' => '/tmp/mysql-backup',
          'backuprotate' => '25',
          'delete_before_dump' => true,
          'execpath' => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
          'maxallowedpacket' => '1M' }
      end

      context 'with time included' do
        let(:params) do
          { time: [23, 59, 30, 12, 6] }.merge(default_params)
        end

        it {
          expect(subject).to contain_cron('mysql-backup').with(
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
          expect(subject).to contain_cron('mysql-backup').with(
            command: '/usr/local/sbin/mysqlbackup.sh',
            ensure: 'present',
            hour: 23,
            minute: 5,
          )
        }
      end

      context 'with compression_command' do
        let(:params) do
          {
            compression_command: 'TEST -TEST',
            compression_extension: '.TEST'
          }.merge(default_params)
        end

        it {
          expect(subject).to contain_file('mysqlbackup.sh').with_content(
            %r{(\| TEST -TEST)},
          )
          expect(subject).to contain_file('mysqlbackup.sh').with_content(
            %r{(\.TEST)},
          )
          expect(subject).not_to contain_package('bzip2')
        }
      end

      context 'with file_per_database and excludedatabases' do
        let(:params) do
          {
            'file_per_database' => true,
            'excludedatabases' => ['information_schema', 'performance_schema']
          }.merge(default_params)
        end

        it {
          expect(subject).to contain_file('mysqlbackup.sh').with_content(
            %r{information_schema\\\|performance_schema},
          )
        }
      end
    end
  end
end
