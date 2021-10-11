# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'mysql::server::backup class' do
  context 'should work with no errors' do
    pp = <<-MANIFEST
        class { 'mysql::server': root_password => 'password' }
        mysql::db { [
          'backup1',
          'backup2'
        ]:
          user     => 'backup',
          password => 'secret',
          charset  => #{fetch_charset},
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
    MANIFEST
    it 'when configuring mysql backups' do
      idempotent_apply(pp)
    end
  end

  describe 'mysqlbackup.sh', if: Gem::Version.new(mysql_version) < Gem::Version.new('5.7.0') do
    it 'runs mysqlbackup.sh with no errors' do
      run_shell('/usr/local/sbin/mysqlbackup.sh') do |r|
        expect(r.stderr).to eq('')
      end
    end

    it 'dumps all databases to single file' do
      run_shell('ls -l /tmp/backups/mysql_backup_*-*.sql.bz2 | wc -l') do |r|
        expect(r.stdout).to match(%r{1})
        expect(r.exit_code).to be_zero
      end
    end

    context 'should create one file per database per run' do
      it 'executes mysqlbackup.sh a second time' do
        run_shell('sleep 1')
        run_shell('/usr/local/sbin/mysqlbackup.sh')
      end

      it 'creates at least one backup tarball' do
        run_shell('ls -l /tmp/backups/mysql_backup_*-*.sql.bz2 | wc -l') do |r|
          expect(r.stdout).to match(%r{2})
          expect(r.exit_code).to be_zero
        end
      end
    end
  end

  context 'with one file per database' do
    context 'should work with no errors' do
      pp = <<-MANIFEST
          class { 'mysql::server': root_password => 'password' }
          mysql::db { [
            'backup1',
            'backup2'
          ]:
            user     => 'backup',
            password => 'secret',
            charset  => #{fetch_charset},
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
      MANIFEST
      it 'when configuring mysql backups' do
        idempotent_apply(pp)
      end
    end

    describe 'mysqlbackup.sh', if: Gem::Version.new(mysql_version) < Gem::Version.new('5.7.0') do
      it 'runs mysqlbackup.sh with no errors without root credentials' do
        run_shell('HOME=/tmp/dontreadrootcredentials /usr/local/sbin/mysqlbackup.sh') do |r|
          expect(r.stderr).to eq('')
        end
      end

      it 'creates one file per database' do
        ['backup1', 'backup2'].each do |database|
          run_shell("ls -l /tmp/backups/mysql_backup_#{database}_*-*.sql.bz2 | wc -l") do |r|
            expect(r.stdout).to match(%r{1})
            expect(r.exit_code).to be_zero
          end
        end
      end

      it 'executes mysqlbackup.sh a second time' do
        run_shell('sleep 1')
        run_shell('HOME=/tmp/dontreadrootcredentials /usr/local/sbin/mysqlbackup.sh')
      end

      it 'has one file per database per run' do
        ['backup1', 'backup2'].each do |database|
          run_shell("ls -l /tmp/backups/mysql_backup_#{database}_*-*.sql.bz2 | wc -l") do |r|
            expect(r.stdout).to match(%r{2})
            expect(r.exit_code).to be_zero
          end
        end
      end
    end
  end

  context 'with xtrabackup enabled' do
    context 'should work with no errors', if: ((os[:family] == 'debian') || (os[:family] == 'ubuntu' && os[:release] =~ %r{^16\.04|^18\.04}) || (os[:family] == 'redhat' && os[:release].to_i > 6)) do
      pp = <<-MANIFEST
          class { 'mysql::server': root_password => 'password' }
          mysql::db { [
            'backup1',
            'backup2'
          ]:
            user     => 'backup',
            password => 'secret',
            charset  => #{fetch_charset},
          }
          case $facts['os']['family'] {
            /Debian/: {
              if versioncmp($::operatingsystemmajrelease, '8') >= 0 {
                $source_url = "http://repo.percona.com/apt/percona-release_1.0-22.generic_all.deb"
              } else {
                $source_url = "http://repo.percona.com/apt/percona-release_latest.${facts['os']['distro']['codename']}_all.deb"
              }

              file { '/tmp/percona-release_latest.deb':
                ensure => present,
                source => $source_url,
              }
              ensure_packages('gnupg')
              ensure_packages('gnupg2')
              ensure_packages('curl')
              ensure_packages('percona-release',{
                ensure   => present,
                provider => 'dpkg',
                source   => '/tmp/percona-release_latest.deb',
                notify   => Exec['apt-get update'],
              })
              exec { 'apt-get update':
                path        => '/usr/bin:/usr/sbin:/bin:/sbin',
                refreshonly => true,
              }
            }
            /RedHat/: {
              # RHEL/CentOS 5 is no longer supported by Percona, but older versions
              # of the repository are still available.
              if versioncmp($::operatingsystemmajrelease, '6') >= 0 {
                $percona_url = 'http://repo.percona.com/yum/percona-release-latest.noarch.rpm'
                $epel_url = "https://download.fedoraproject.org/pub/epel/epel-release-latest-${facts['os']['release']['major']}.noarch.rpm"
              } else {
                $percona_url = 'http://repo.percona.com/yum/release/5/os/noarch/percona-release-0.1-3.noarch.rpm'
                $epel_url = 'https://archives.fedoraproject.org/pub/archive/epel/epel-release-latest-5.noarch.rpm'
              }
              ensure_packages('percona-release',{
                ensure   => present,
                provider => 'rpm',
                source   => $percona_url,
              })
              ensure_packages('epel-release',{
                ensure   => present,
                provider => 'rpm',
                source   => $epel_url,
              })
              if ($facts['os']['name'] == 'Scientific') {
                # $releasever resolves to '6.10' instead of '6' which breaks Percona repos
                file { '/etc/yum/vars/releasever':
                  ensure  => present,
                  content => '6',
                }
              }
            }
            default: { }
          }
          class { 'mysql::server::backup':
            backupuser     => 'myuser',
            backuppassword => 'mypassword',
            backupdir      => '/tmp/xtrabackups',
            provider       => 'xtrabackup',
            execpath       => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
          }
      MANIFEST
      it 'when configuring mysql backup' do
        idempotent_apply(pp)
      end
    end

    describe 'xtrabackup.sh', if: Gem::Version.new(mysql_version) < Gem::Version.new('5.7.0') && ((os[:family] == 'debian' && os[:release].to_i >= 9) || (os[:family] == 'ubuntu' && os[:release] =~ %r{^16\.04|^18\.04}) || (os[:family] == 'redhat' && os[:release].to_i > 6) || ((fetch_os_name != 'oraclelinux' || fetch_os_name != 'scientific') && os[:release].to_i == 7)) do # rubocop:disable Layout/LineLength
      it 'runs xtrabackup.sh full backup with no errors' do
        run_shell('/usr/local/sbin/xtrabackup.sh --target-dir=/tmp/xtrabackups/$(date +%F)_full --backup 2>&1 | tee /tmp/xtrabackup_full.log') do |r|
          expect(r.exit_code).to be_zero
        end
      end

      it 'xtrabackup reports success for the full backup' do
        # NOTE: Once support for CentOS 6 is dropped, we should check for "completed OK" instead.
        run_shell('grep "xtrabackup: Transaction log of lsn" /tmp/xtrabackup_full.log') do |r|
          expect(r.exit_code).to be_zero
        end
      end

      it 'creates a subdirectory for the full backup' do
        run_shell('find /tmp/xtrabackups -mindepth 1 -maxdepth 1 -type d -name $(date +%Y)\*full | wc -l') do |r|
          expect(r.stdout).to match(%r{1})
          expect(r.exit_code).to be_zero
        end
      end

      it 'runs xtrabackup.sh incremental backup with no errors' do
        run_shell('sleep 1')
        run_shell('/usr/local/sbin/xtrabackup.sh --incremental-basedir=/tmp/xtrabackups/$(date +%F)_full --target-dir=/tmp/xtrabackups/$(date +%F_%H-%M-%S) --backup 2>&1 | tee /tmp/xtrabackup_inc.log') do |r| # rubocop:disable Layout/LineLength
          expect(r.exit_code).to be_zero
        end
      end

      it 'xtrabackup reports success for the incremental backup' do
        # NOTE: Once support for CentOS 6 is dropped, we should check for "completed OK" instead.
        run_shell('grep "xtrabackup: Transaction log of lsn" /tmp/xtrabackup_inc.log') do |r|
          expect(r.exit_code).to be_zero
        end
      end

      it 'creates a new subdirectory for each backup' do
        run_shell('find /tmp/xtrabackups -mindepth 1 -maxdepth 1 -type d -name $(date +%Y)\* | wc -l') do |r|
          expect(r.stdout).to match(%r{2})
          expect(r.exit_code).to be_zero
        end
      end
    end
  end

  context 'with xtrabackup enabled and incremental backups disabled' do
    context 'should work with no errors', if: ((os[:family] == 'debian' && os[:release].to_i >= 9) || (os[:family] == 'ubuntu' && os[:release] =~ %r{^16\.04|^18\.04}) || (os[:family] == 'redhat' && os[:release].to_i > 6) || ((fetch_os_name != 'oraclelinux' || fetch_os_name != 'scientific') && os[:release].to_i == 7)) do # rubocop:disable Layout/LineLength
      pp = <<-MANIFEST
          class { 'mysql::server': root_password => 'password' }
          mysql::db { [
            'backup1',
            'backup2'
          ]:
            user     => 'backup',
            password => 'secret',
            charset  => #{fetch_charset},
          }
          case $facts['os']['family'] {
            /Debian/: {
              $source_url = "http://repo.percona.com/apt/percona-release_1.0-22.generic_all.deb"

              file { '/tmp/percona-release_latest.deb':
                ensure => present,
                source => $source_url,
              }
              ensure_packages('gnupg')
              ensure_packages('gnupg2')
              ensure_packages('percona-release',{
                ensure   => present,
                provider => 'dpkg',
                source   => '/tmp/percona-release_latest.deb',
                notify   => Exec['apt-get update'],
              })
              exec { 'apt-get update':
                path        => '/usr/bin:/usr/sbin:/bin:/sbin',
                refreshonly => true,
              }
            }
            /RedHat/: {
              $percona_url = 'http://repo.percona.com/yum/percona-release-latest.noarch.rpm'
              $epel_url = "https://download.fedoraproject.org/pub/epel/epel-release-latest-${facts['os']['release']['major']}.noarch.rpm"
              ensure_packages('percona-release',{
                ensure   => present,
                provider => 'rpm',
                source   => $percona_url,
              })
              ensure_packages('epel-release',{
                ensure   => present,
                provider => 'rpm',
                source   => $epel_url,
              })
              if ($facts['os']['name'] == 'Scientific') {
                # $releasever resolves to '6.10' instead of '6' which breaks Percona repos
                file { '/etc/yum/vars/releasever':
                  ensure  => present,
                  content => '6',
                }
              }
            }
            default: { }
          }
          class { 'mysql::server::backup':
            backupuser          => 'myuser',
            backuppassword      => 'mypassword',
            backupdir           => '/tmp/xtrabackups',
            provider            => 'xtrabackup',
            incremental_backups => false,
            execpath            => '/usr/bin:/usr/sbin:/bin:/sbin:/opt/zimbra/bin',
          }
      MANIFEST
      it 'when configuring mysql backup' do
        idempotent_apply(pp)
      end
    end

    describe 'xtrabackup.sh', if: Gem::Version.new(mysql_version) < Gem::Version.new('5.7.0') && ((os[:family] == 'debian' && os[:release].to_i >= 9) || (os[:family] == 'ubuntu' && os[:release] =~ %r{^16\.04|^18\.04}) || (os[:family] == 'redhat' && os[:release].to_i > 6) || ((fetch_os_name != 'oraclelinux' || fetch_os_name != 'scientific') && os[:release].to_i == 7)) do # rubocop:disable Layout/LineLength
      it 'runs xtrabackup.sh with no errors' do
        run_shell('/usr/local/sbin/xtrabackup.sh --target-dir=/tmp/xtrabackups/$(date +%F_%H-%M-%S) --backup 2>&1 | tee /tmp/xtrabackup.log') do |r|
          expect(r.exit_code).to be_zero
        end
      end

      it 'xtrabackup reports success for the backup' do
        # NOTE: Once support for CentOS 6 is dropped, we should check for "completed OK" instead.
        run_shell('grep "xtrabackup: Transaction log of lsn" /tmp/xtrabackup.log') do |r|
          expect(r.exit_code).to be_zero
        end
      end
    end
  end
end
