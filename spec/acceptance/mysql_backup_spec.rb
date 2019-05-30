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
    before(:all) do
      pre_run
    end

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
  # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
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
    before(:all) do
      pre_run
    end

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
    # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
  end
end
