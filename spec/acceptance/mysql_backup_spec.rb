require 'spec_helper_acceptance'

describe 'mysql::server::backup class' do
  context 'should work with no errors' do
    it 'when configuring mysql backups' do
      pp = <<-EOS
        class { 'mysql::server': override_options => { 'root_password' => 'password' } }
        mysql::db { 'backup1':
          user     => 'backup',
          password => 'secret',
        }

        class { 'mysql::server::backup':
          backupuser     => 'myuser',
          backuppassword => 'mypassword',
          backupdir      => '/tmp/backups',
          backupcompress => true,
        }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).to eq("")
      end
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stderr).to eq("")
        expect(r.exit_code).to be_zero
      end
    end
  end

  describe 'mysqlbackup.sh' do
    it 'should run mysqlbackup.sh with no errors' do
      shell("/usr/local/sbin/mysqlbackup.sh") do |r|
        expect(r.stderr).to eq("")
      end
    end

    it 'should dump all databases to single file' do
      shell('ls /tmp/backups/ | grep -c "mysql_backup_backup1_[0-9][0-9]*-[0-9][0-9]*.sql.bz2"') do |r|
        expect(r.stdout).to match(/\d*[13579]/)
      end
    end

    context 'should create one file per database per run' do
      it 'executes mysqlbackup.sh a second time' do
        shell('sleep 1')
        shell('/usr/local/sbin/mysqlbackup.sh')
      end

      it 'creates at least one backup tarball' do
        expect(shell('ls /tmp/backups/ | grep -c "mysql_backup_backup1_[0-9][0-9]*-[0-9][0-9]*.sql.bz2"').stdout).to match(/\d*[02468]/)
      end
    end
  end
end
