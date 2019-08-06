require 'spec_helper'

describe 'mysql::backup::xtrabackup' do
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
        { 'backupdir' => '/tmp' }
      end

      context 'with defaults' do
        let(:params) do
          default_params
        end

        it 'contains the wrapper script' do
          is_expected.to contain_file('xtrabackup.sh').with_content(
            %r{(\n*^xtrabackup\s+.*\$@)},
          )
        end

        it 'contains the weekly cronjob' do
          is_expected.to contain_cron('xtrabackup-weekly')
            .with(
              ensure: 'present',
              command: '/usr/local/sbin/xtrabackup.sh --target-dir=/tmp --backup',
              user: 'root',
              hour: '23',
              minute: '5',
              weekday: '0',
            )
            .that_requires('Package[percona-xtrabackup]')
        end

        it 'contains the daily cronjob for weekdays 1-6' do
          is_expected.to contain_cron('xtrabackup-daily')
            .with(
              ensure: 'present',
              command: '/usr/local/sbin/xtrabackup.sh --incremental-basedir=/tmp --target-dir=/tmp/$(date +\%F_\%H-\%M-\%S) --backup',
              user: 'root',
              hour: '23',
              minute: '5',
              weekday: '1-6',
            )
            .that_requires('Package[percona-xtrabackup]')
        end
      end

      context 'with backupuser and backuppassword' do
        let(:params) do
          { backupuser: 'backupuser',
            backuppassword: 'backuppassword' }.merge(default_params)
        end

        it 'contains the defined mysql user' do
          is_expected.to contain_mysql_user('backupuser@localhost')
            .with(
              ensure: 'present',
              password_hash: '*4110E08DF51E70A4BA1D4E33A84205E38CF3FE58',
            )
            .that_requires('Class[mysql::server::root_password]')

          is_expected.to contain_mysql_grant('backupuser@localhost/*.*')
            .with(
              ensure: 'present',
              user: 'backupuser@localhost',
              table: '*.*',
              privileges: ['RELOAD', 'PROCESS', 'LOCK TABLES', 'REPLICATION CLIENT'],
            )
            .that_requires('Mysql_user[backupuser@localhost]')
        end
      end

      context 'with additional cron args' do
        let(:params) do
          { additional_cron_args: '--backup --skip-ssl' }.merge(default_params)
        end

        it 'contains the weekly cronjob' do
          is_expected.to contain_cron('xtrabackup-weekly')
            .with(
              ensure: 'present',
              command: '/usr/local/sbin/xtrabackup.sh --target-dir=/tmp --backup --skip-ssl',
              user: 'root',
              hour: '23',
              minute: '5',
              weekday: '0',
            )
            .that_requires('Package[percona-xtrabackup]')
        end

        it 'contains the daily cronjob for weekdays 1-6' do
          is_expected.to contain_cron('xtrabackup-daily')
            .with(
              ensure: 'present',
              command: '/usr/local/sbin/xtrabackup.sh --incremental-basedir=/tmp --target-dir=/tmp/$(date +\%F_\%H-\%M-\%S) --backup --skip-ssl',
              user: 'root',
              hour: '23',
              minute: '5',
              weekday: '1-6',
            )
            .that_requires('Package[percona-xtrabackup]')
        end
      end

      context 'with deactivated incremental backups' do
        let(:params) do
          { incremental_backups: false }.merge(default_params)
        end

        it 'not contains the weekly cronjob' do
          is_expected.not_to contain_cron('xtrabackup-weekly')
        end

        it 'contains the daily cronjob with all weekdays' do
          is_expected.to contain_cron('xtrabackup-daily').with(
            ensure: 'present',
            command: '/usr/local/sbin/xtrabackup.sh --target-dir=/tmp --backup',
            user: 'root',
            hour: '23',
            minute: '5',
            weekday: '*',
          )
        end
      end

      context 'with prescript defined' do
        let(:params) do
          { prescript: ['rsync -a /tmp backup01.local-lan:',
                        'rsync -a /tmp backup02.local-lan:'] }.merge(default_params)
        end

        it 'contains the prescript' do
          is_expected.to contain_file('xtrabackup.sh').with_content(
            %r{.*rsync -a \/tmp backup01.local-lan:\n\nrsync -a \/tmp backup02.local-lan:.*},
          )
        end
      end

      context 'with postscript defined' do
        let(:params) do
          { postscript: ['rsync -a /tmp backup01.local-lan:',
                         'rsync -a /tmp backup02.local-lan:'] }.merge(default_params)
        end

        it 'contains the prostscript' do
          is_expected.to contain_file('xtrabackup.sh').with_content(
            %r{.*rsync -a \/tmp backup01.local-lan:\n\nrsync -a \/tmp backup02.local-lan:.*},
          )
        end
      end

      context 'with mariabackup' do
        let(:params) do
          { backupmethod: 'mariabackup' }.merge(default_params)
        end

        it 'contain the mariabackup executor' do
          is_expected.to contain_file('xtrabackup.sh').with_content(
            %r{(\n*^mariabackup\s+.*\$@)},
          )
        end
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups
end
