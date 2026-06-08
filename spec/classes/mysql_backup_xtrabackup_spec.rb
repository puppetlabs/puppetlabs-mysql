# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::backup::xtrabackup' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) do
        <<-MANIFEST
          class { 'mysql::server': }
        MANIFEST
      end
      let(:facts) do
        facts.merge(root_home: '/root',
                    mysql_version: '5.7',
                    mysld_version: 'mysqld  Ver 5.7.38 for Linux on x86_64 (MySQL Community Server - (GPL)')
      end

      let(:default_params) do
        { 'backupdir' => '/tmp' }
      end

      context 'with defaults' do
        let(:params) do
          default_params
        end

        it 'does not contain the touch command' do
          expect(subject).to contain_file('xtrabackup.sh').without_content(
            %r{(^\s+touch\s+$)},
          )
        end

        it 'contains the wrapper script' do
          expect(subject).to contain_file('xtrabackup.sh').with_content(
            %r{(\n*^xtrabackup\s+.*\$@)},
          )
        end

        package = if facts[:os]['family'] == 'RedHat'
                    if Puppet::Util::Package.versioncmp(facts[:os]['release']['major'], '8') >= 0
                      'percona-xtrabackup-24'
                    else
                      'percona-xtrabackup'
                    end
                  elsif facts[:os]['name'] == 'Debian'
                    'percona-xtrabackup-24'
                  elsif facts[:os]['name'] == 'Ubuntu'
                    if Puppet::Util::Package.versioncmp(facts[:os]['release']['major'], '20') < 0 &&
                       Puppet::Util::Package.versioncmp(facts[:os]['release']['major'], '16') >= 0
                      'percona-xtrabackup'
                    else
                      'percona-xtrabackup-24'
                    end
                  elsif facts[:os]['family'] == 'Suse'
                    'xtrabackup'
                  else
                    'percona-xtrabackup'
                  end

        it 'contains the weekly cronjob' do
          expect(subject).to contain_cron('xtrabackup-weekly')
            .with(
              ensure: 'present',
              command: '/usr/local/sbin/xtrabackup.sh --target-dir=/tmp/$(date +\%F)_full --backup',
              user: 'root',
              hour: '23',
              minute: '5',
              weekday: '0',
            )
            .that_requires("Package[#{package}]")
        end

        it 'contains the daily cronjob for weekdays 1-6' do
          dateformat = case facts[:os]['name']
                       when 'FreeBSD', 'OpenBSD'
                         '$(date -v-sun +\%F)_full'
                       else
                         '$(date -d "last sunday" +\%F)_full'
                       end
          expect(subject).to contain_cron('xtrabackup-daily')
            .with(
              ensure: 'present',
              command: "/usr/local/sbin/xtrabackup.sh --incremental-basedir=/tmp/#{dateformat} --target-dir=/tmp/$(date +\\%F_\\%H-\\%M-\\%S) --backup",
              user: 'root',
              hour: '23',
              minute: '5',
              weekday: '1-6',
            )
            .that_requires("Package[#{package}]")
        end
      end

      context 'with backupuser and backuppassword' do
        let(:params) do
          { backupuser: 'backupuser',
            backuppassword: 'backuppassword' }.merge(default_params)
        end

        it 'contains the defined mysql user' do
          expect(subject).to contain_mysql_user('backupuser@localhost')
            .with(
              ensure: 'present',
              password_hash: '*4110E08DF51E70A4BA1D4E33A84205E38CF3FE58',
            )
            .that_requires('Class[mysql::server::root_password]')

          expect(subject).to contain_mysql_grant('backupuser@localhost/*.*')
            .with(
              ensure: 'present',
              user: 'backupuser@localhost',
              table: '*.*',
              privileges:
              if (facts[:os]['name'] == 'Debian' && Puppet::Util::Package.versioncmp(facts[:os]['release']['major'], '11') >= 0) ||
                (facts[:os]['name'] == 'Ubuntu' && Puppet::Util::Package.versioncmp(facts[:os]['release']['major'], '22') >= 0)
                ['BINLOG MONITOR', 'RELOAD', 'PROCESS', 'LOCK TABLES']
              else
                ['RELOAD', 'PROCESS', 'LOCK TABLES', 'REPLICATION CLIENT']
              end,
            )
            .that_requires('Mysql_user[backupuser@localhost]')
        end

        context 'with MySQL version 5.7' do
          let(:facts) do
            facts.merge(mysql_version: '5.7')
          end

          it {
            expect(subject).not_to contain_mysql_grant('backupuser@localhost/performance_schema.keyring_component_status')
            expect(subject).not_to contain_mysql_grant('backupuser@localhost/performance_schema.log_status')
            expect(subject).not_to contain_mysql_grant('backupuser@localhost/*.*')
              .with(
                ensure: 'present',
                user: 'backupuser@localhost',
                table: '*.*',
                privileges:
                  ['BACKUP_ADMIN'],
              )
              .that_requires('Mysql_user[backupuser@localhost]')
          }
        end

        context 'with MySQL version 8.0' do
          let(:facts) do
            facts.merge(mysql_version: '8.0',
                        mysld_version: 'mysqld  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)')
          end

          it {
            expect(subject).to contain_mysql_grant('backupuser@localhost/*.*')
              .with(
                ensure: 'present',
                user: 'backupuser@localhost',
                table: '*.*',
                privileges:
                if (facts[:os]['name'] == 'Debian' && Puppet::Util::Package.versioncmp(facts[:os]['release']['major'], '11') >= 0) ||
                  (facts[:os]['name'] == 'Ubuntu' && Puppet::Util::Package.versioncmp(facts[:os]['release']['major'], '22') >= 0)
                  ['BINLOG MONITOR', 'RELOAD', 'PROCESS', 'LOCK TABLES', 'BACKUP_ADMIN']
                else
                  ['RELOAD', 'PROCESS', 'LOCK TABLES', 'REPLICATION CLIENT', 'BACKUP_ADMIN']
                end,
              )
              .that_requires('Mysql_user[backupuser@localhost]')
            expect(subject).to contain_mysql_grant('backupuser@localhost/performance_schema.keyring_component_status')
              .with(
                ensure: 'present',
                user: 'backupuser@localhost',
                table: 'performance_schema.keyring_component_status',
                privileges:
                  ['SELECT'],
              )
              .that_requires('Mysql_user[backupuser@localhost]')

            expect(subject).to contain_mysql_grant('backupuser@localhost/performance_schema.log_status')
              .with(
                ensure: 'present',
                user: 'backupuser@localhost',
                table: 'performance_schema.log_status',
                privileges:
                  ['SELECT'],
              )
              .that_requires('Mysql_user[backupuser@localhost]')
          }
        end
      end

      context 'with additional cron args' do
        let(:params) do
          { additional_cron_args: '--backup --skip-ssl' }.merge(default_params)
        end

        package = if facts[:os]['family'] == 'RedHat'
                    if Puppet::Util::Package.versioncmp(facts[:os]['release']['major'], '8') >= 0
                      'percona-xtrabackup-24'
                    else
                      'percona-xtrabackup'
                    end
                  elsif facts[:os]['name'] == 'Debian'
                    'percona-xtrabackup-24'
                  elsif facts[:os]['name'] == 'Ubuntu'
                    if Puppet::Util::Package.versioncmp(facts[:os]['release']['major'], '20') < 0 &&
                       Puppet::Util::Package.versioncmp(facts[:os]['release']['major'], '16') >= 0
                      'percona-xtrabackup'
                    else
                      'percona-xtrabackup-24'
                    end
                  elsif facts[:os]['family'] == 'Suse'
                    'xtrabackup'
                  else
                    'percona-xtrabackup'
                  end

        dateformat = case facts[:os]['family']
                     when 'FreeBSD', 'OpenBSD'
                       '$(date -v-sun +\%F)_full'
                     else
                       '$(date -d "last sunday" +\%F)_full'
                     end

        it 'contains the weekly cronjob' do
          expect(subject).to contain_cron('xtrabackup-weekly')
            .with(
              ensure: 'present',
              command: '/usr/local/sbin/xtrabackup.sh --target-dir=/tmp/$(date +\%F)_full --backup --skip-ssl',
              user: 'root',
              hour: '23',
              minute: '5',
              weekday: '0',
            )
            .that_requires("Package[#{package}]")
        end

        it 'contains the daily cronjob for weekdays 1-6' do
          expect(subject).to contain_cron('xtrabackup-daily')
            .with(
              ensure: 'present',
              command: "/usr/local/sbin/xtrabackup.sh --incremental-basedir=/tmp/#{dateformat} --target-dir=/tmp/$(date +\\%F_\\%H-\\%M-\\%S) --backup --skip-ssl",
              user: 'root',
              hour: '23',
              minute: '5',
              weekday: '1-6',
            )
            .that_requires("Package[#{package}]")
        end
      end

      context 'with deactivated incremental backups' do
        let(:params) do
          { incremental_backups: false }.merge(default_params)
        end

        it 'not contains the weekly cronjob' do
          expect(subject).not_to contain_cron('xtrabackup-weekly')
        end

        it 'contains the daily cronjob with all weekdays' do
          expect(subject).to contain_cron('xtrabackup-daily').with(
            ensure: 'present',
            command: '/usr/local/sbin/xtrabackup.sh --target-dir=/tmp/$(date +\%F_\%H-\%M-\%S) --backup',
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
          expect(subject).to contain_file('xtrabackup.sh').with_content(
            %r{.*rsync -a /tmp backup01.local-lan:\n\nrsync -a /tmp backup02.local-lan:.*},
          )
        end
      end

      context 'with postscript defined' do
        let(:params) do
          { postscript: ['rsync -a /tmp backup01.local-lan:',
                         'rsync -a /tmp backup02.local-lan:'] }.merge(default_params)
        end

        it 'contains the prostscript' do
          expect(subject).to contain_file('xtrabackup.sh').with_content(
            %r{.*rsync -a /tmp backup01.local-lan:\n\nrsync -a /tmp backup02.local-lan:.*},
          )
        end
      end

      context 'with mariabackup' do
        let(:params) do
          { backupmethod: 'mariabackup',
            backupmethod_package: 'mariadb-backup' }.merge(default_params)
        end

        it 'contain the mariabackup executor' do
          expect(subject).to contain_file('xtrabackup.sh').with_content(
            %r{(\n*^mariabackup\s+.*\$@)},
          )
        end
      end

      context 'with backup_success_file_path' do
        let(:params) do
          { backup_success_file_path: '/tmp/backup_success' }.merge(default_params)
        end

        it 'contain the touch /tmp/backup_success command' do
          expect(subject).to contain_file('xtrabackup.sh').with_content(
            %r{(^\s+touch /tmp/backup_success$)},
          )
        end
      end
    end
  end
end
