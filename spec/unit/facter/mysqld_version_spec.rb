require 'spec_helper'

describe Facter::Util::Fact.to_s do
  {
    'mysql-5.5' =>
    {
      :version => '5.5.46',
      :string => '/usr/sbin/mysqld  Ver 5.5.46-log for Linux on x86_64 (MySQL Community Server (GPL))',
      :mysql_type => 'mysql',
    },
    'mysql-5.6' =>
    {
      :version => '5.6.27',
      :string => '/usr/sbin/mysqld  Ver 5.6.27 for Linux on x86_64 (MySQL Community Server (GPL))',
      :mysql_type => 'mysql',
    },
    'mysql-5.7.1' =>
    {
      :version => '5.7.1',
      :string => '/usr/sbin/mysqld  Ver 5.7.1 for Linux on x86_64 (MySQL Community Server (GPL))',
      :mysql_type => 'mysql',
    },
    'mysql-5.7.6' =>
    {
      :version => '5.7.8',
      :string => '/usr/sbin/mysqld  Ver 5.7.8-rc for Linux on x86_64 (MySQL Community Server (GPL))',
      :mysql_type => 'mysql',
    },
    'mariadb-10.0' =>
    {
      :version => '10.0.21',
      :string => '/usr/sbin/mysqld  Ver 10.0.21-MariaDB for Linux on x86_64 (MariaDB Server)',
      :mysql_type => 'mariadb',
    },
    'mariadb-10.0-deb8' =>
    {
      :version => '10.0.23',
      :string => '/usr/sbin/mysqld (mysqld 10.0.23-MariaDB-0+deb8u1)',
      :mysql_type => 'mariadb',
    },
    'percona-5.5' =>
    {
      :version => '5.5.39',
      :string => 'mysqld  Ver 5.5.39-36.0-55 for Linux on x86_64 (Percona XtraDB Cluster (GPL), Release rel36.0, Revision 824, WSREP version 25.11, wsrep_25.11.r4023)',
      :mysql_type => 'percona',
    },
  }.each_pair do
    |name,hsh|
    describe name do
      before :each do
        Facter.clear
        Facter::Util::Resolution.stubs(:exec).with('sysctl -n hw.ncpu 2>/dev/null').returns('2')
        Facter::Util::Resolution.stubs(:exec).with('mysqld -V 2>/dev/null').returns(hsh[:string])
      end
      context 'mysqld_version' do
        it {
          expect(Facter.fact('mysqld_version').value).to eq(hsh[:version])
        }
      end
      context 'mysqld_type' do
        it {
          expect(Facter.fact('mysqld_type').value).to eq(hsh[:mysql_type])
        }
      end
    end
  end
end
