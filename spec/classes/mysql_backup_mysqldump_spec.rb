# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::backup::mysqldump' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) do
        <<-MANIFEST
          class { 'mysql::server': }
        MANIFEST
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

        it { is_expected.to contain_class('mysql::params') }

        it {
          is_expected.to contain_cron('mysql-backup').with(
            command: '/usr/local/sbin/mysqlbackup.sh',
            ensure: 'present',
            hour: 23,
            minute: 5,
          )
        }

        it {
          is_expected.to contain_package('bzip2')
        }

        it {
          package_name = (facts[:os]['family'] == 'RedHat') ? 'cronie' : 'cron'
          is_expected.to contain_package(package_name)
        }
      end

      context 'without backupcomress' do
        let(:params) do
          { 'backupcompress' => false, }.merge(default_params)
        end

        it {
          is_expected.not_to contain_package('bzip2')
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
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{(\| TEST -TEST)},
          )
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{(\.TEST)},
          )
          is_expected.not_to contain_package('bzip2')
        }
      end

      context 'with file_per_database and excludedatabases' do
        let(:params) do
          {
            'file_per_database' => true,
            'excludedatabases' => ['information_schema']
          }.merge(default_params)
        end

        it {
          is_expected.to contain_file('mysqlbackup.sh').with_content(
            %r{information_schema},
          )
        }
      end
    end
  end
end
