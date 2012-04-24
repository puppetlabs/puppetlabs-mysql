require 'spec_helper'

describe 'mysql::backup' do

  let(:params) {
    { 'backupuser'     => 'testuser',
      'backuppassword' => 'testpass',
      'backupdir'      => '/tmp',
    }
  }

  it { should contain_database_user('testuser@localhost')}

  it { should contain_database_grant('testuser@localhost').with(
    :privileges => [ 'select_priv', 'reload_priv', 'lock_tables_priv' ]
  )}

  it { should contain_cron('mysql-backup').with(
    :command => '/usr/local/sbin/mysqlbackup.sh',
    :ensure  => 'present'
  )}

  it { should contain_file('mysqlbackup.sh').with(
    :path   => '/usr/local/sbin/mysqlbackup.sh',
    :ensure => 'present'
  )}

  it { should contain_file('mysqlbackupdir').with(
    :path   => '/tmp',
    :ensure => 'directory'
  )}

end
