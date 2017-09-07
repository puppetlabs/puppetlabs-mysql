require 'spec_helper_acceptance'
require 'puppet/util/package'
require_relative './mysql_helper.rb'

describe 'mysql::server::backup class' do
  context 'should work with no errors' do
    let(:pp) do
      <<-EOS
      class { 'mysql::server': root_password => 'password' }
      mysql::db { [
        'backup1',
        'backup2'
      ]:
        user     => 'backup',
        password => 'secret',
      }

      class { 'mysql::server::backup':
        backupuser     => 'myuser',
        backuppassword => 'mypassword',
        backupdir      => '/tmp/backups',
        backupcompress => true,
        postscript     => [
          'rm -rf /var/tmp/mysqlbackups',
          'rm -f /var/tmp/mysqlbackups.done',
          'cp -r /tmp/backups /var/tmp/mysqlbackups',
          'touch /var/tmp/mysqlbackups.done',
        ],
        execpath      => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
      }
    EOS
    end

    it 'when configuring mysql backups' do
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
    end
  end

  describe 'mysqlbackup.sh' do
    pre_run
    unless version_is_greater_than('5.7.0')
      it 'runs mysqlbackup.sh with no errors' do
        shell('/usr/local/sbin/mysqlbackup.sh') do |r|
          expect(r.stderr).to eq('')
        end
      end

      it 'dumps all databases to single file' do
        shell('ls -l /tmp/backups/mysql_backup_*-*.sql.bz2 | wc -l') do |r|
          check_script_output(result: r, match: 1)
        end
      end

      context 'should create one file per database per run' do
        it 'executes mysqlbackup.sh a second time' do
          shell('sleep 1')
          shell('/usr/local/sbin/mysqlbackup.sh')
        end

        it 'creates at least one backup tarball' do
          shell('ls -l /tmp/backups/mysql_backup_*-*.sql.bz2 | wc -l') do |r|
            check_script_output(result: r, match: 2)
          end
        end
      end
    end
  end

  context 'with one file per database' do
    context 'should work with no errors' do
      let(:pp) do
        <<-EOS
          class { 'mysql::server': root_password => 'password' }
          mysql::db { [
            'backup1',
            'backup2'
          ]:
            user     => 'backup',
            password => 'secret',
          }

          class { 'mysql::server::backup':
            backupuser        => 'myuser',
            backuppassword    => 'mypassword',
            backupdir         => '/tmp/backups',
            backupcompress    => true,
            file_per_database => true,
            postscript        => [
              'rm -rf /var/tmp/mysqlbackups',
              'rm -f /var/tmp/mysqlbackups.done',
              'cp -r /tmp/backups /var/tmp/mysqlbackups',
              'touch /var/tmp/mysqlbackups.done',
            ],
            execpath          => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
          }
        EOS
      end

      it 'when configuring mysql backups' do
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_failures: true)
      end
    end

    describe 'mysqlbackup.sh' do
      pre_run
      unless version_is_greater_than('5.7.0')
        it 'runs mysqlbackup.sh with no errors without root credentials' do
          shell('HOME=/tmp/dontreadrootcredentials /usr/local/sbin/mysqlbackup.sh') do |r|
            expect(r.stderr).to eq('')
          end
        end

        it 'creates one file per database' do
          %w[backup1 backup2].each do |database|
            shell("ls -l /tmp/backups/mysql_backup_#{database}_*-*.sql.bz2 | wc -l") do |r|
              check_script_output(result: r, match: 1)
            end
          end
        end

        it 'executes mysqlbackup.sh a second time' do
          shell('sleep 1')
          shell('HOME=/tmp/dontreadrootcredentials /usr/local/sbin/mysqlbackup.sh')
        end

        it 'has one file per database per run' do
          %w[backup1 backup2].each do |database|
            shell("ls -l /tmp/backups/mysql_backup_#{database}_*-*.sql.bz2 | wc -l") do |r|
              check_script_output(result: r, match: 2)
            end
          end
        end
      end
    end
  end

  context 'with triggers and routines' do
    let(:pp) do
      <<-EOS
        class { 'mysql::server': root_password => 'password' }
        mysql::db { [
          'backup1',
          'backup2'
          ]:
          user => 'backup',
          password => 'secret',
        }
        package { 'bzip2':
          ensure => present,
        }
        class { 'mysql::server::backup':
          backupuser => 'myuser',
          backuppassword => 'mypassword',
          backupdir => '/tmp/backups',
          backupcompress => true,
          file_per_database => true,
          include_triggers => #{version_is_greater_than('5.1.5')},
          include_routines => true,
          postscript => [
            'rm -rf /var/tmp/mysqlbackups',
            'rm -f /var/tmp/mysqlbackups.done',
            'cp -r /tmp/backups /var/tmp/mysqlbackups',
            'touch /var/tmp/mysqlbackups.done',
          ],
          execpath => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
          require => Package['bzip2'],
        }
      EOS
    end

    it 'when configuring mysql backups with triggers and routines' do
      pre_run
      apply_manifest(pp, catch_failures: true)
    end

    pre_run
    unless version_is_greater_than('5.7.0')
      it 'runs mysqlbackup.sh with no errors' do
        shell('/usr/local/sbin/mysqlbackup.sh') do |r|
          expect(r.stderr).to eq('')
        end
      end
    end
  end
end
