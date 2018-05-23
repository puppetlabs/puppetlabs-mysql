require 'spec_helper'

describe Puppet::Type.type(:mysql_user).provider(:mysql) do
  # Output of mysqld -V
  $mysql_version_string_hash = {
      'mysql-5.5' =>
      {
        :version => '5.5.46',
        :string => '/usr/sbin/mysqld  Ver 5.5.46-log for Linux on x86_64 (MySQL Community Server (GPL))',
        :mysql_type => 'mysql',
      },
      'mysql-5.6' =>
      {
        version: '5.6.27',
        string: '/usr/sbin/mysqld  Ver 5.6.27 for Linux on x86_64 (MySQL Community Server (GPL))',
        mysql_type: 'mysql',
      },
      'mysql-5.7.1' =>
      {
        version: '5.7.1',
        string: '/usr/sbin/mysqld  Ver 5.7.1 for Linux on x86_64 (MySQL Community Server (GPL))',
        mysql_type: 'mysql',
      },
      'mysql-5.7.6' =>
      {
        version: '5.7.8',
        string: '/usr/sbin/mysqld  Ver 5.7.8-rc for Linux on x86_64 (MySQL Community Server (GPL))',
        mysql_type: 'mysql',
      },
    'mariadb-10.0' =>
      {
        version: '10.0.21',
        string: '/usr/sbin/mysqld  Ver 10.0.21-MariaDB for Linux on x86_64 (MariaDB Server)',
        mysql_type: 'mariadb',
      },
    'mariadb-10.0-deb8' =>
      {
        version: '10.0.23',
        string: '/usr/sbin/mysqld (mysqld 10.0.23-MariaDB-0+deb8u1)',
        mysql_type: 'mariadb',
      },
    'percona-5.5' =>
      {
        version: '5.5.39',
        string: 'mysqld  Ver 5.5.39-36.0-55 for Linux on x86_64 (Percona XtraDB Cluster (GPL), Release rel36.0, Revision 824, WSREP version 25.11, wsrep_25.11.r4023)',
        mysql_type: 'percona',
      },
  }

  def mysql_version_facts(ver)
    Facter.stubs(:value).with(:mysqld_version_string).returns($mysql_version_string_hash[ver][:string])
    Facter.stubs(:value).with(:mysqld_version).returns($mysql_version_string_hash[ver][:version])
    Facter.stubs(:value).with(:mysql_version).returns($mysql_version_string_hash[ver][:version])
    Facter.stubs(:value).with(:mysqld_type).returns($mysql_version_string_hash[ver][:mysql_type])
    # overwrite memoized version
    #provider.class.instance_variable_set(:@mysqld_version, $mysql_version_string_hash[ver][:version])
  end

  let(:defaults_file) { '--defaults-extra-file=/root/.my.cnf' }
  let(:system_database) { '--database=mysql' }
  let(:newhash) { '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5' }

  let(:raw_users) do
    # rubocop:disable Layout/IndentHeredoc
    <<-SQL_OUTPUT
root@127.0.0.1
root@::1
@localhost
debian-sys-maint@localhost
root@localhost
usvn_user@localhost
@vagrant-ubuntu-raring-64
    SQL_OUTPUT
    # rubocop:enable Layout/IndentHeredoc
  end

  let(:parsed_users) { ['root@127.0.0.1', 'root@::1', '@localhost', 'debian-sys-maint@localhost', 'root@localhost', 'usvn_user@localhost', '@vagrant-ubuntu-raring-64'] }
  let(:provider) { resource.provider }
  let(:instance) { provider.class.instances.first }
  let(:resource) do
    Puppet::Type.type(:mysql_user).new(
      ensure: :present,
      password_hash: '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4',
      name: 'joe@localhost',
      max_user_connections: '10',
      max_connections_per_hour: '10',
      max_queries_per_hour: '10',
      max_updates_per_hour: '10',
      provider: described_class.name,
    )
  end

  before :each do
    # Set up the stubs for an instances call.
    Facter.stubs(:value).with(:root_home).returns('/root')
    mysql_version_facts('mysql-5.6')
    Puppet::Util.stubs(:which).with('mysql').returns('/usr/bin/mysql')
    Puppet::Util.stubs(:which).with('mysqld').returns('/usr/sbin/mysqld')
    File.stubs(:file?).with('/root/.my.cnf').returns(true)
    provider.class.stubs(:mysql_caller).with("SELECT CONCAT(User, '@',Host) AS User FROM mysql.user", 'regular').returns('joe@localhost')
    provider.class.stubs(:mysql_caller).with("SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, SSL_TYPE, SSL_CIPHER, X509_ISSUER, X509_SUBJECT, PASSWORD /*!50508 , PLUGIN */ FROM mysql.user WHERE CONCAT(user, '@', host) = 'joe@localhost'", 'regular').returns('10 10 10 10     *6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4') # rubocop:disable Metrics/LineLength
  end

  describe 'self.instances' do
    before :each do
      provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT CONCAT(User, '@',Host) AS User FROM mysql.user"]).returns(raw_users)
    end
    it 'returns an array of users MySQL 5.5' do
      mysql_version_facts('mysql-5.5')
      parsed_users.each do |user|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, SSL_TYPE, SSL_CIPHER, X509_ISSUER, X509_SUBJECT, PASSWORD /*!50508 , PLUGIN */ FROM mysql.user WHERE CONCAT(user, '@', host) = '#{user}'"]).returns('10 10 10 10     ')
      end

      usernames = provider.class.instances.map { |x| x.name }
      expect(parsed_users).to match_array(usernames)
    end
    it 'returns an array of users MySQL 5.6' do
      mysql_version_facts('mysql-5.6')
      parsed_users.each do |user|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, SSL_TYPE, SSL_CIPHER, X509_ISSUER, X509_SUBJECT, PASSWORD /*!50508 , PLUGIN */ FROM mysql.user WHERE CONCAT(user, '@', host) = '#{user}'"]).returns('10 10 10 10     ')
      end

      usernames = provider.class.instances.map { |x| x.name }
      expect(parsed_users).to match_array(usernames)
    end
    it 'returns an array of users MySQL >= 5.7.0 < 5.7.6' do
      mysql_version_facts('mysql-5.7.1')
      parsed_users.each do |user|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, SSL_TYPE, SSL_CIPHER, X509_ISSUER, X509_SUBJECT, PASSWORD /*!50508 , PLUGIN */ FROM mysql.user WHERE CONCAT(user, '@', host) = '#{user}'"]).returns('10 10 10 10     ')
      end

      usernames = provider.class.instances.map { |x| x.name }
      expect(parsed_users).to match_array(usernames)
    end
    it 'returns an array of users MySQL >= 5.7.6' do
      mysql_version_facts('mysql-5.7.6')
      parsed_users.each do |user|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, SSL_TYPE, SSL_CIPHER, X509_ISSUER, X509_SUBJECT, AUTHENTICATION_STRING, PLUGIN FROM mysql.user WHERE CONCAT(user, '@', host) = '#{user}'"]).returns('10 10 10 10     ')
      end

      usernames = provider.class.instances.map { |x| x.name }
      expect(parsed_users).to match_array(usernames)
    end
    it 'returns an array of users mariadb 10.0' do
      mysql_version_facts('mariadb-10.0')
      parsed_users.each do |user|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, SSL_TYPE, SSL_CIPHER, X509_ISSUER, X509_SUBJECT, PASSWORD /*!50508 , PLUGIN */ FROM mysql.user WHERE CONCAT(user, '@', host) = '#{user}'"]).returns('10 10 10 10     ')
      end

      usernames = provider.class.instances.map { |x| x.name }
      expect(parsed_users).to match_array(usernames)
    end
    it 'returns an array of users percona 5.5' do
      mysql_version_facts('percona-5.5')
      parsed_users.each do |user|
        provider.class.stubs(:mysql).with([defaults_file, '-NBe', "SELECT MAX_USER_CONNECTIONS, MAX_CONNECTIONS, MAX_QUESTIONS, MAX_UPDATES, SSL_TYPE, SSL_CIPHER, X509_ISSUER, X509_SUBJECT, PASSWORD /*!50508 , PLUGIN */ FROM mysql.user WHERE CONCAT(user, '@', host) = '#{user}'"]).returns('10 10 10 10     ')
      end

      usernames = provider.class.instances.map { |x| x.name }
      expect(parsed_users).to match_array(usernames)
    end
  end

  describe 'self.prefetch' do
    it 'exists' do
      provider.class.instances
      provider.class.prefetch({})
    end
  end

  describe 'create' do
    it 'makes a user' do
      provider.class.expects(:mysql_caller).with("CREATE USER 'joe'@'localhost' IDENTIFIED BY PASSWORD '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4'", 'system')
      provider.class.expects(:mysql_caller).with("GRANT USAGE ON *.* TO 'joe'@'localhost' WITH MAX_USER_CONNECTIONS 10 MAX_CONNECTIONS_PER_HOUR 10 MAX_QUERIES_PER_HOUR 10 MAX_UPDATES_PER_HOUR 10", 'system') # rubocop:disable Metrics/LineLength
      provider.class.expects(:mysql_caller).with("GRANT USAGE ON *.* TO 'joe'@'localhost' REQUIRE NONE", 'system')
      provider.expects(:exists?).returns(true)
      expect(provider.create).to be_truthy
    end
  end

  describe 'destroy' do
    it 'removes a user if present' do
      provider.class.expects(:mysql_caller).with("DROP USER 'joe'@'localhost'", 'system')
      provider.expects(:exists?).returns(false)
      expect(provider.destroy).to be_truthy
    end
    it 'removes a user using IF EXISTS' do
      provider.class.instance_variable_set(:@mysqld_version_string, '5.7.1')

      provider.class.expects(:mysql_caller).with("DROP USER IF EXISTS 'joe'@'localhost'", 'system')
      expect(provider.destroy).to be_truthy
    end
  end

  describe 'exists?' do
    it 'checks if user exists' do
      expect(instance).to be_exists
    end
  end

  describe 'self.mysqld_version' do
    it 'uses the mysqld_version fact' do
       Facter.stubs(:value).with(:mysqld_version).returns('5.6.24')
       expect(provider.mysqld_version).to eq '5.6.24'
    end
  end

    describe 'self.mysqld_version_string' do
    it 'uses the mysqld_version_string fact' do
       val = '/usr/sbin/mysqld  Ver 5.5.46-log for Linux on x86_64 (MySQL Community Server (GPL))'
       Facter.stubs(:value).with(:mysqld_version_string).returns(val)
       expect(provider.mysqld_version_string).to eq val
    end
  end

  describe 'self.defaults_file' do
    it 'sets --defaults-extra-file' do
      File.stubs(:file?).with('/root/.my.cnf').returns(true)
      expect(provider.defaults_file).to eq '--defaults-extra-file=/root/.my.cnf'
    end
    it 'fails if file missing' do
      File.expects(:file?).with('/root/.my.cnf').returns(false)
      expect(provider.defaults_file).to be_nil
    end
  end

  describe 'password_hash' do
    it 'returns a hash' do
      expect(instance.password_hash).to eq('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4')
    end
  end

  describe 'password_hash=' do
    it 'changes the hash mysql 5.5' do
      mysql_version_facts('mysql-5.5')
      provider.expects(:mysql).with([defaults_file, system_database, '-e', "SET PASSWORD FOR 'joe'@'localhost' = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'"]).returns('0')

      provider.expects(:password_hash).returns('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
      provider.password_hash = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'
    end
    it 'changes the hash mysql 5.6' do
      mysql_version_facts('mysql-5.6')
      provider.expects(:mysql).with([defaults_file, system_database, '-e', "SET PASSWORD FOR 'joe'@'localhost' = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'"]).returns('0')

      provider.expects(:password_hash).returns('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
      provider.password_hash = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'
    end
    it 'changes the hash mysql < 5.7.6' do
      mysql_version_facts('mysql-5.7.1')
      provider.expects(:mysql).with([defaults_file, system_database, '-e', "SET PASSWORD FOR 'joe'@'localhost' = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'"]).returns('0')

      provider.expects(:password_hash).returns('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
      provider.password_hash = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'
    end
    it 'changes the hash MySQL >= 5.7.6' do
      mysql_version_facts('mysql-5.7.6')
      provider.expects(:mysql).with([defaults_file, system_database, '-e', "ALTER USER 'joe'@'localhost' IDENTIFIED WITH mysql_native_password AS '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'"]).returns('0')

      provider.expects(:password_hash).returns('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
      provider.password_hash = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'
    end
    it 'changes the hash mariadb-10.0' do
      mysql_version_facts('mariadb-10.0')
      provider.expects(:mysql).with([defaults_file, system_database, '-e', "SET PASSWORD FOR 'joe'@'localhost' = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'"]).returns('0')

      provider.expects(:password_hash).returns('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
      provider.password_hash = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'
    end
    it 'changes the hash percona-5.5' do
      mysql_version_facts('percona-5.5')
      provider.expects(:mysql).with([defaults_file, system_database, '-e', "SET PASSWORD FOR 'joe'@'localhost' = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'"]).returns('0')

      provider.expects(:password_hash).returns('*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5')
      provider.password_hash = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF5'
    end
  end

  describe 'plugin=' do
    context 'auth_socket' do
      context 'MySQL < 5.7.6' do
        it 'changes the authentication plugin' do
          provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mysql-5.7.1'][:string])
          provider.class.expects(:mysql_caller).with("UPDATE mysql.user SET plugin = 'auth_socket', password = '' WHERE CONCAT(user, '@', host) = 'joe@localhost'", 'system').returns('0')

          provider.expects(:plugin).returns('auth_socket')
          provider.plugin = 'auth_socket'
        end
      end

      context 'MySQL >= 5.7.6' do
        it 'changes the authentication plugin' do
          provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mysql-5.7.6'][:string])
          provider.class.expects(:mysql_caller).with("ALTER USER 'joe'@'localhost' IDENTIFIED WITH 'auth_socket'", 'system').returns('0')

          provider.expects(:plugin).returns('auth_socket')
          provider.plugin = 'auth_socket'
        end
      end
    end

    context 'mysql_native_password' do
      context 'MySQL < 5.7.6' do
        it 'changes the authentication plugin' do
          provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mysql-5.7.1'][:string])
          provider.class.expects(:mysql_caller).with("UPDATE mysql.user SET plugin = 'mysql_native_password', password = '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4' WHERE CONCAT(user, '@', host) = 'joe@localhost'", 'system').returns('0') # rubocop:disable Metrics/LineLength

          provider.expects(:plugin).returns('mysql_native_password')
          provider.plugin = 'mysql_native_password'
        end
      end

      context 'MySQL >= 5.7.6' do
        it 'changes the authentication plugin' do
          provider.class.instance_variable_set(:@mysqld_version_string, mysql_version_string_hash['mysql-5.7.6'][:string])
          provider.class.expects(:mysql_caller).with("ALTER USER 'joe'@'localhost' IDENTIFIED WITH 'mysql_native_password' AS '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4'", 'system').returns('0') # rubocop:disable Metrics/LineLength

          provider.expects(:plugin).returns('mysql_native_password')
          provider.plugin = 'mysql_native_password'
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups
  end

  describe 'tls_options=' do
    it 'adds SSL option grant in mysql 5.5' do
      mysql_version_facts('mysql-5.5')
      provider.expects(:mysql).with([defaults_file, system_database, '-e', "GRANT USAGE ON *.* TO 'joe'@'localhost' REQUIRE NONE"]).returns('0')

      provider.expects(:tls_options).returns(['NONE'])
      provider.tls_options = ['NONE']
    end
    it 'adds SSL option grant in mysql 5.6' do
      mysql_version_facts('mysql-5.6')
      provider.expects(:mysql).with([defaults_file, system_database, '-e', "GRANT USAGE ON *.* TO 'joe'@'localhost' REQUIRE NONE"]).returns('0')

      provider.expects(:tls_options).returns(['NONE'])
      provider.tls_options = ['NONE']
    end
    it 'adds SSL option grant in mysql < 5.7.6' do
      mysql_version_facts('mysql-5.7.1')
      provider.expects(:mysql).with([defaults_file, system_database, '-e', "GRANT USAGE ON *.* TO 'joe'@'localhost' REQUIRE NONE"]).returns('0')

      provider.expects(:tls_options).returns(['NONE'])
      provider.tls_options = ['NONE']
    end
    it 'adds SSL option grant in mysql >= 5.7.6' do
      mysql_version_facts('mysql-5.7.6')
      provider.expects(:mysql).with([defaults_file, system_database, '-e', "ALTER USER 'joe'@'localhost' REQUIRE NONE"]).returns('0')

      provider.expects(:tls_options).returns(['NONE'])
      provider.tls_options = ['NONE']
    end
    it 'adds SSL option grant in mariadb-10.0' do
      mysql_version_facts('mariadb-10.0')
      provider.expects(:mysql).with([defaults_file, system_database, '-e', "GRANT USAGE ON *.* TO 'joe'@'localhost' REQUIRE NONE"]).returns('0')

      provider.expects(:tls_options).returns(['NONE'])
      provider.tls_options = ['NONE']
    end
  end

  ['max_user_connections', 'max_connections_per_hour', 'max_queries_per_hour', 'max_updates_per_hour'].each do |property|
    describe property do
      it "returns #{property}" do
        expect(instance.send(property.to_s.to_sym)).to eq('10')
      end
    end

    describe "#{property}=" do
      it "changes #{property}" do
        provider.class.expects(:mysql_caller).with("GRANT USAGE ON *.* TO 'joe'@'localhost' WITH #{property.upcase} 42", 'system').returns('0')
        provider.expects(property.to_sym).returns('42')
        provider.send("#{property}=".to_sym, '42')
      end
    end
  end
end
