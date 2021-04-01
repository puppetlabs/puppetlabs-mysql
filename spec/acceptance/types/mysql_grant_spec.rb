# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'mysql_grant' do
  before(:all) do
    pp = <<-MANIFEST
      class { 'mysql::server':
        root_password => 'password',
      }
    MANIFEST

    apply_manifest(pp, catch_failures: true)
  end

  describe 'missing privileges for user' do
    pp = <<-MANIFEST
        mysql_user { 'test1@tester':
          ensure => present,
        }
        mysql_grant { 'test1@tester/test.*':
          ensure  => 'present',
          table   => 'test.*',
          user    => 'test1@tester',
          require => Mysql_user['test1@tester'],
        }
    MANIFEST
    it 'fails' do
      result = apply_manifest(pp, expect_failures: true)
      expect(result.stderr).to contain(%r{`privileges` `parameter` is required})
    end

    it 'does not find the user' do
      result = run_shell('mysql -NBe "SHOW GRANTS FOR test1@tester"', expect_failures: true)
      expect(result.stderr).to contain(%r{There is no such grant defined for user 'test1' on host 'tester'})
    end
  end

  describe 'missing table for user' do
    pp = <<-MANIFEST
        mysql_user { 'atest@tester':
          ensure => present,
        }
        mysql_grant { 'atest@tester/test.*':
          ensure     => 'present',
          user       => 'atest@tester',
          privileges => ['ALL'],
          require    => Mysql_user['atest@tester'],
        }
    MANIFEST
    it 'fails' do
      apply_manifest(pp, expect_failures: true)
    end

    it 'does not find the user' do
      result = run_shell('mysql -NBe "SHOW GRANTS FOR atest@tester"', expect_failures: true)
      expect(result.stderr).to contain(%r{There is no such grant defined for user 'atest' on host 'tester'})
    end
  end

  describe 'adding privileges' do
    pp = <<-MANIFEST
        mysql_user { 'test2@tester':
          ensure => present,
        }
        mysql_grant { 'test2@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test2@tester',
          privileges => ['SELECT', 'UPDATE'],
          require    => Mysql_user['test2@tester'],
        }
    MANIFEST
    it 'works without errors' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'finds the user #stdout' do
      result = run_shell('mysql -NBe "SHOW GRANTS FOR test2@tester"')
      expect(result.stdout).to contain(%r{GRANT SELECT, UPDATE.*TO ['|`]test2['|`]@['|`]tester['|`]})
      expect(result.stderr).to be_empty
    end
  end

  describe 'adding privileges with special character in name' do
    pp = <<-MANIFEST
        mysql_user { 'test-2@tester':
          ensure => present,
        }
        mysql_grant { 'test-2@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test-2@tester',
          privileges => ['SELECT', 'UPDATE'],
          require    => Mysql_user['test-2@tester'],
        }
    MANIFEST
    it 'works without errors' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'finds the user #stdout' do
      result = run_shell("mysql -NBe \"SHOW GRANTS FOR 'test-2'@tester\"")
      expect(result.stdout).to contain(%r{GRANT SELECT, UPDATE.*TO ['|`]test-2['|`]@['|`]tester['|`]})
      expect(result.stderr).to be_empty
    end
  end

  describe 'adding option' do
    pp = <<-MANIFEST
        mysql_user { 'test3@tester':
          ensure => present,
        }
        mysql_grant { 'test3@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test3@tester',
          options    => ['GRANT'],
          privileges => ['SELECT', 'UPDATE'],
          require    => Mysql_user['test3@tester'],
        }
    MANIFEST
    it 'works without errors' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'finds the user #stdout' do
      result = run_shell('mysql -NBe "SHOW GRANTS FOR test3@tester"')
      expect(result.stdout).to contain(%r{GRANT SELECT, UPDATE ON `test`.* TO ['|`]test3['|`]@['|`]tester['|`] WITH GRANT OPTION$})
      expect(result.stderr).to be_empty
    end
  end

  describe 'adding all privileges without table' do
    pp = <<-MANIFEST
        mysql_user { 'test4@tester':
          ensure => present,
        }
        mysql_grant { 'test4@tester/test.*':
          ensure     => 'present',
          user       => 'test4@tester',
          options    => ['GRANT'],
          privileges => ['SELECT', 'UPDATE', 'ALL'],
          require    => Mysql_user['test4@tester'],
        }
    MANIFEST
    it 'fails' do
      result = apply_manifest(pp, expect_failures: true)
      expect(result.stderr).to contain(%r{`table` `parameter` is required.})
    end
  end

  describe 'adding all privileges' do
    pp = <<-MANIFEST
        mysql_user { 'test4@tester':
          ensure => present,
        }
        mysql_grant { 'test4@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test4@tester',
          options    => ['GRANT'],
          privileges => ['SELECT', 'UPDATE', 'ALL'],
          require    => Mysql_user['test4@tester'],
        }
    MANIFEST
    it 'onlies try to apply ALL' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'finds the user #stdout' do
      result = run_shell('mysql -NBe "SHOW GRANTS FOR test4@tester"')
      expect(result.stdout).to contain(%r{GRANT ALL PRIVILEGES ON `test`.* TO ['|`]test4['|`]@['|`]tester['|`] WITH GRANT OPTION})
      expect(result.stderr).to be_empty
    end
  end

  # Test combinations of user@host to ensure all cases work.
  describe 'short hostname' do
    pp = <<-MANIFEST
        mysql_user { 'test@short':
          ensure => present,
        }
        mysql_grant { 'test@short/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@short',
          privileges => 'ALL',
          require    => Mysql_user['test@short'],
        }
        mysql_user { 'test@long.hostname.com':
          ensure => present,
        }
        mysql_grant { 'test@long.hostname.com/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@long.hostname.com',
          privileges => 'ALL',
          require    => Mysql_user['test@long.hostname.com'],
        }
        mysql_user { 'test@192.168.5.6':
          ensure => present,
        }
        mysql_grant { 'test@192.168.5.6/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@192.168.5.6',
          privileges => 'ALL',
          require    => Mysql_user['test@192.168.5.6'],
        }
        mysql_user { 'test@2607:f0d0:1002:0051:0000:0000:0000:0004':
          ensure => present,
        }
        mysql_grant { 'test@2607:f0d0:1002:0051:0000:0000:0000:0004/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@2607:f0d0:1002:0051:0000:0000:0000:0004',
          privileges => 'ALL',
          require    => Mysql_user['test@2607:f0d0:1002:0051:0000:0000:0000:0004'],
        }
        mysql_user { 'test@::1/128':
          ensure => present,
        }
        mysql_grant { 'test@::1/128/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@::1/128',
          privileges => 'ALL',
          require    => Mysql_user['test@::1/128'],
        }
    MANIFEST
    it 'applies' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'finds short hostname #stdout' do
      result = run_shell('mysql -NBe "SHOW GRANTS FOR test@short"')
      expect(result.stdout).to contain(%r{GRANT ALL PRIVILEGES ON ['|`]test['|`].* TO ['|`]test['|`]@['|`]short['|`]})
      expect(result.stderr).to be_empty
    end

    it 'finds long hostname #stdout' do
      run_shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'long.hostname.com'\"") do |r|
        expect(r.stdout).to match(%r{GRANT ALL PRIVILEGES ON ['|`]test['|`].* TO ['|`]test['|`]@['|`]long.hostname.com['|`]})
        expect(r.stderr).to be_empty
      end
    end

    it 'finds ipv4 #stdout' do
      run_shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'192.168.5.6'\"") do |r|
        expect(r.stdout).to match(%r{GRANT ALL PRIVILEGES ON ['|`]test['|`].* TO ['|`]test['|`]@['|`]192.168.5.6['|`]})
        expect(r.stderr).to be_empty
      end
    end

    it 'finds ipv6 #stdout' do
      run_shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'2607:f0d0:1002:0051:0000:0000:0000:0004'\"") do |r|
        expect(r.stdout).to match(%r{GRANT ALL PRIVILEGES ON ['|`]test['|`].* TO ['|`]test['|`]@['|`]2607:f0d0:1002:0051:0000:0000:0000:0004['|`]})
        expect(r.stderr).to be_empty
      end
    end

    it 'finds short ipv6 #stdout' do
      run_shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'::1/128'\"") do |r|
        expect(r.stdout).to match(%r{GRANT ALL PRIVILEGES ON ['|`]test['|`].* TO ['|`]test['|`]@['|`]::1\/128['|`]})
        expect(r.stderr).to be_empty
      end
    end
  end

  # On Ubuntu 20.04 'ALL' now returns as the sum of it's constitute parts and so require a specific test
  describe 'ALL privilege on newer MySQL versions', if: os[:family] == 'ubuntu' && os[:release] =~ %r{^20\.04} do
    pp_one = <<-MANIFEST
        mysql_user { 'all@localhost':
          ensure => present,
        }
        mysql_grant { 'all@localhost/*.*':
          user       => 'all@localhost',
          privileges => ['ALL'],
          table      => '*.*',
          require    => Mysql_user['all@localhost'],
        }
    MANIFEST
    it "create ['ALL'] privs" do
      apply_manifest(pp_one, catch_failures: true)
    end

    pp_two = <<-MANIFEST
        mysql_user { 'all@localhost':
          ensure => present,
        }
        mysql_grant { 'all@localhost/*.*':
          user       => 'all@localhost',
          privileges => ['ALTER', 'ALTER ROUTINE', 'CREATE', 'CREATE ROLE', 'CREATE ROUTINE', 'CREATE TABLESPACE', 'CREATE TEMPORARY TABLES', 'CREATE USER', 'CREATE VIEW', 'DELETE', 'DROP', 'DROP ROLE', 'EVENT', 'EXECUTE', 'FILE', 'INDEX', 'INSERT', 'LOCK TABLES', 'PROCESS', 'REFERENCES', 'RELOAD', 'REPLICATION CLIENT', 'REPLICATION SLAVE', 'SELECT', 'SHOW DATABASES', 'SHOW VIEW', 'SHUTDOWN', 'SUPER', 'TRIGGER', 'UPDATE'],
          table      => '*.*',
          require    => Mysql_user['all@localhost'],
        }
    MANIFEST
    it "create ['ALL'] constitute parts privs" do
      apply_manifest(pp_two, catch_changes: true)
    end
  end

  describe 'complex test' do
    # On Ubuntu 20.04 'ALL' now returns as the sum of it's constitute parts and so is no longer idempotent when set
    privileges = if os[:family] == 'ubuntu' && os[:release] =~ %r{^20\.04}
                   "['SELECT', 'INSERT', 'UPDATE']"
                 else
                   "['ALL']"
                 end
    pp = <<-MANIFEST
        $dbSubnet = '10.10.10.%'

        mysql_database { 'foo':
          ensure => present,
        }

        exec { 'mysql-create-table':
          command     => '/usr/bin/mysql -NBe "CREATE TABLE foo.bar (name VARCHAR(20))"',
          environment => "HOME=${::root_home}",
          unless      => '/usr/bin/mysql -NBe "SELECT 1 FROM foo.bar LIMIT 1;"',
          require     => Mysql_database['foo'],
        }

        Mysql_grant {
          ensure     => present,
          options    => ['GRANT'],
          privileges => #{privileges},
          table      => '*.*',
          require    => [ Mysql_database['foo'], Exec['mysql-create-table'] ],
        }

        mysql_user { "user1@${dbSubnet}":
          ensure => present,
        }
        mysql_grant { "user1@${dbSubnet}/*.*":
          user       => "user1@${dbSubnet}",
          require    => Mysql_user["user1@${dbSubnet}"],
        }
        mysql_user { "user2@${dbSubnet}":
          ensure => present,
        }
        mysql_grant { "user2@${dbSubnet}/foo.bar":
          privileges => ['SELECT', 'INSERT', 'UPDATE'],
          user       => "user2@${dbSubnet}",
          table      => 'foo.bar',
          require    => Mysql_user["user2@${dbSubnet}"],
        }
        mysql_user { "user3@${dbSubnet}":
          ensure => present,
        }
        mysql_grant { "user3@${dbSubnet}/foo.*":
          privileges => ['SELECT', 'INSERT', 'UPDATE'],
          user       => "user3@${dbSubnet}",
          table      => 'foo.*',
          require    => Mysql_user["user3@${dbSubnet}"],
        }
        mysql_user { 'web@%':
          ensure => present,
        }
        mysql_grant { 'web@%/*.*':
          user       => 'web@%',
          require    => Mysql_user['web@%'],
        }
        mysql_user { "web@${dbSubnet}":
          ensure => present,
        }
        mysql_grant { "web@${dbSubnet}/*.*":
          user       => "web@${dbSubnet}",
          require    => Mysql_user["web@${dbSubnet}"],
        }
        mysql_user { "web@${::networking['ip']}":
          ensure => present,
        }
        mysql_grant { "web@${::networking['ip']}/*.*":
          user       => "web@${::networking['ip']}",
          require    => Mysql_user["web@${::networking['ip']}"],
        }
        mysql_user { 'web@localhost':
          ensure => present,
        }
        mysql_grant { 'web@localhost/*.*':
          user       => 'web@localhost',
          require    => Mysql_user['web@localhost'],
        }
    MANIFEST
    it 'setup mysql::server' do
      idempotent_apply(pp)
    end
  end

  describe 'lower case privileges' do
    pp_one = <<-MANIFEST
        mysql_user { 'lowercase@localhost':
          ensure => present,
        }
        mysql_grant { 'lowercase@localhost/*.*':
          user       => 'lowercase@localhost',
          privileges => ['SELECT', 'INSERT', 'UPDATE'],
          table      => '*.*',
          require    => Mysql_user['lowercase@localhost'],
        }
    MANIFEST
    it "create ['SELECT', 'INSERT', 'UPDATE'] privs" do
      apply_manifest(pp_one, catch_failures: true)
    end

    pp_two = <<-MANIFEST
        mysql_user { 'lowercase@localhost':
          ensure => present,
        }
        mysql_grant { 'lowercase@localhost/*.*':
          user       => 'lowercase@localhost',
          privileges => ['select', 'insert', 'update'],
          table      => '*.*',
          require    => Mysql_user['lowercase@localhost'],
        }
    MANIFEST
    it "create lowercase ['select', 'insert', 'update'] privs" do
      apply_manifest(pp_two, catch_changes: true)
    end
  end

  describe 'adding procedure privileges' do
    pp = <<-MANIFEST
        exec { 'simpleproc-create':
          command => 'mysql --user="root" --password="password" --database=mysql --delimiter="//" -NBe "CREATE PROCEDURE simpleproc (OUT param1 INT) BEGIN SELECT COUNT(*) INTO param1 FROM t; end//"',
          path    => '/usr/bin/',
          before  => Mysql_user['test2@tester'],
        }
        mysql_user { 'test2@tester':
          ensure => present,
        }
        mysql_grant { 'test2@tester/PROCEDURE mysql.simpleproc':
          ensure     => 'present',
          table      => 'PROCEDURE mysql.simpleproc',
          user       => 'test2@tester',
          privileges => ['EXECUTE'],
          require    => Mysql_user['test2@tester'],
        }
    MANIFEST
    it 'works without errors' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'finds the user #stdout' do
      result = run_shell('mysql -NBe "SHOW GRANTS FOR test2@tester"')
      expect(result.stdout).to match(%r{GRANT EXECUTE ON PROCEDURE `mysql`.`simpleproc` TO ['|`]test2['|`]@['|`]tester['|`]})
      expect(result.stderr).to be_empty
    end
  end

  describe 'adding function privileges' do
    it 'works without errors' do
      pp = <<-EOS
        exec { 'simplefunc-create':
          command => '/usr/bin/mysql --user="root" --password="password" --database=mysql -NBe "CREATE FUNCTION simplefunc (s CHAR(20)) RETURNS CHAR(50) DETERMINISTIC RETURN CONCAT(\\'Hello, \\', s, \\'!\\')"',
          before  => Mysql_user['test3@tester'],
        }

        mysql_user { 'test3@tester':
          ensure => 'present',
        }

        mysql_grant { 'test3@tester/FUNCTION mysql.simplefunc':
          ensure     => 'present',
          table      => 'FUNCTION mysql.simplefunc',
          user       => 'test3@tester',
          privileges => ['EXECUTE'],
          require    => Mysql_user['test3@tester'],
        }
      EOS

      apply_manifest(pp, catch_failures: true)
    end
    # rubocop:enable RSpec/ExampleLength
    it 'finds the user' do
      result = run_shell('mysql -NBe "SHOW GRANTS FOR test3@tester"')
      expect(result.stdout).to match(%r{GRANT EXECUTE ON FUNCTION `mysql`.`simplefunc` TO ['|`]test3['|`]@['|`]tester['|`]})
      expect(result.stderr).to be_empty
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe 'proxy privilieges' do
    pre_run

    describe 'adding proxy privileges', if: Gem::Version.new(mysql_version) > Gem::Version.new('5.5.0') do
      pp = <<-MANIFEST
        mysql_user { 'proxy1@tester':
          ensure => present,
        }
        mysql_grant { 'proxy1@tester/proxy_user@proxy_host':
          ensure     => 'present',
          table      => 'proxy_user@proxy_host',
          user       => 'proxy1@tester',
          privileges => ['PROXY'],
          require    => Mysql_user['proxy1@tester'],
        }
      MANIFEST
      it 'works without errors when version greater than 5.5.0' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the user #stdout' do
        run_shell('mysql -NBe "SHOW GRANTS FOR proxy1@tester"') do |r|
          expect(r.stdout).to match(%r{GRANT PROXY ON 'proxy_user'@'proxy_host' TO ['|`]proxy1['|`]@['|`]tester['|`]})
          expect(r.stderr).to be_empty
        end
      end
    end

    describe 'removing proxy privileges', if: Gem::Version.new(mysql_version) > Gem::Version.new('5.5.0') do
      pp = <<-MANIFEST
        mysql_user { 'proxy1@tester':
          ensure => present,
        }
        mysql_grant { 'proxy1@tester/proxy_user@proxy_host':
          ensure     => 'absent',
          table      => 'proxy_user@proxy_host',
          user       => 'proxy1@tester',
          privileges => ['PROXY'],
          require    => Mysql_user['proxy1@tester'],
        }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the user #stdout' do
        run_shell('mysql -NBe "SHOW GRANTS FOR proxy1@tester"') do |r|
          expect(r.stdout).not_to match(%r{GRANT PROXY ON 'proxy_user'@'proxy_host' TO ['|`]proxy1['|`]@['|`]tester['|`]})
          expect(r.stderr).to be_empty
        end
      end
    end

    describe 'adding proxy privileges with other privileges', if: Gem::Version.new(mysql_version) > Gem::Version.new('5.5.0') do
      pp = <<-MANIFEST
        mysql_user { 'proxy2@tester':
          ensure => present,
        }
        mysql_grant { 'proxy2@tester/proxy_user@proxy_host':
          ensure     => 'present',
          table      => 'proxy_user@proxy_host',
          user       => 'proxy2@tester',
          privileges => ['PROXY', 'SELECT'],
          require    => Mysql_user['proxy2@tester'],
        }
      MANIFEST
      it 'fails' do
        result = apply_manifest(pp, expect_failures: true)
        expect(result.stderr).to match(%r{`privileges` `parameter`: PROXY can only be specified by itself})
      end

      it 'does not find the user' do
        result = run_shell('mysql -NBe "SHOW GRANTS FOR proxy2@tester"', expect_failures: true)
        expect(result.stderr).to match(%r{There is no such grant defined for user 'proxy2' on host 'tester'})
      end
    end

    describe 'adding proxy privileges with mysql version less than 5.5.0', unless: Gem::Version.new(mysql_version) > Gem::Version.new('5.5.0') do
      pp = <<-MANIFEST
        mysql_user { 'proxy3@tester':
          ensure => present,
        }
        mysql_grant { 'proxy3@tester/proxy_user@proxy_host':
          ensure     => 'present',
          table      => 'proxy_user@proxy_host',
          user       => 'proxy3@tester',
          privileges => ['PROXY', 'SELECT'],
          require    => Mysql_user['proxy3@tester'],
        }
      MANIFEST
      it 'fails' do
        result = apply_manifest(pp, expect_failures: true)
        expect(result.stderr).to match(%r{PROXY user not supported on mysql versions < 5\.5\.0}i)
      end

      it 'does not find the user' do
        result = run_shell('mysql -NBe "SHOW GRANTS FOR proxy2@tester"', expect_failures: true)
        expect(result.stderr).to match(%r{There is no such grant defined for user 'proxy2' on host 'tester'})
      end
    end

    describe 'adding proxy privileges with invalid proxy user', if: Gem::Version.new(mysql_version) > Gem::Version.new('5.5.0') do
      pp = <<-MANIFEST
        mysql_user { 'proxy3@tester':
          ensure => present,
        }
        mysql_grant { 'proxy3@tester/invalid_proxy_user':
          ensure     => 'present',
          table      => 'invalid_proxy_user',
          user       => 'proxy3@tester',
          privileges => ['PROXY'],
          require    => Mysql_user['proxy3@tester'],
        }
      MANIFEST
      it 'fails' do
        result = apply_manifest(pp, expect_failures: true)
        expect(result.stderr).to match(%r{`table` `property` for PROXY should be specified as proxy_user@proxy_host.})
      end

      it 'does not find the user' do
        result = run_shell('mysql -NBe "SHOW GRANTS FOR proxy3@tester"', expect_failures: true)
        expect(result.stderr).to contain(%r{There is no such grant defined for user 'proxy3' on host 'tester'})
      end
    end
  end

  describe 'grants with skip-name-resolve specified' do
    pp_one = <<-MANIFEST
        class { 'mysql::server':
          override_options => {
            'mysqld' => {'skip-name-resolve' => true}
          },
          restart          => true,
        }
    MANIFEST
    it 'setup mysql::server' do
      apply_manifest(pp_one, catch_failures: true)
    end

    pp_two = <<-MANIFEST
        mysql_user { 'test@fqdn.com':
          ensure => present,
        }
        mysql_grant { 'test@fqdn.com/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@fqdn.com',
          privileges => 'ALL',
          require    => Mysql_user['test@fqdn.com'],
        }
        mysql_user { 'test@192.168.5.7':
          ensure => present,
        }
        mysql_grant { 'test@192.168.5.7/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@192.168.5.7',
          privileges => 'ALL',
          require    => Mysql_user['test@192.168.5.7'],
        }
    MANIFEST
    it 'applies' do
      apply_manifest(pp_two, catch_failures: true)
    end

    it 'fails with fqdn' do
      pre_run
      unless Gem::Version.new(mysql_version) > Gem::Version.new('5.7.0')
        result = run_shell('mysql -NBe "SHOW GRANTS FOR test@fqdn.com"', expect_failures: true)
        expect(result.stderr).to contain(%r{There is no such grant defined for user 'test' on host 'fqdn.com'})
      end
    end

    it 'finds ipv4 #stdout' do
      run_shell("mysql -NBe \"SHOW GRANTS FOR 'test'@'192.168.5.7'\"") do |r|
        expect(r.stdout).to match(%r{GRANT ALL PRIVILEGES ON `test`.* TO ['|`]test['|`]@['|`]192.168.5.7['|`]})
        expect(r.stderr).to be_empty
      end
    end

    pp_three = <<-MANIFEST
        mysql_user { 'test@fqdn.com':
          ensure => present,
        }
        mysql_grant { 'test@fqdn.com/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@fqdn.com',
          privileges => 'ALL',
          require    => Mysql_user['test@fqdn.com'],
        }
    MANIFEST
    it 'fails to execute while applying' do
      mysql_cmd = run_shell('which mysql').stdout.chomp
      run_shell("mv #{mysql_cmd} #{mysql_cmd}.bak")
      result = apply_manifest(pp_three, expect_failures: true)
      expect(result.stderr).to match(%r{Could not find a suitable provider for mysql_grant})
      run_shell("mv #{mysql_cmd}.bak #{mysql_cmd}")
    end

    pp_four = <<-MANIFEST
        class { 'mysql::server':
          restart          => true,
        }
    MANIFEST
    it 'reset mysql::server config' do
      apply_manifest(pp_four, catch_failures: true)
    end
  end

  describe 'adding privileges to specific table' do
    # Using puppet_apply as a helper
    pp_one = <<-MANIFEST
        class { 'mysql::server': override_options => { 'root_password' => 'password' } }
    MANIFEST
    it 'setup mysql server' do
      apply_manifest(pp_one, catch_failures: true)
    end

    pp_two = <<-MANIFEST
        mysql_user { 'test@localhost':
          ensure => present,
        }
        mysql_grant { 'test@localhost/grant_spec_db.grant_spec_table_doesnt_exist':
          user       => 'test@localhost',
          privileges => ['SELECT'],
          table      => 'grant_spec_db.grant_spec_table_doesnt_exist',
          require    => Mysql_user['test@localhost'],
        }
    MANIFEST
    it 'creates grant on missing table will fail' do
      result = apply_manifest(pp_two, expect_failures: true)
      expect(result.stderr).to match(%r{Table 'grant_spec_db\.grant_spec_table_doesnt_exist' doesn't exist})
    end

    pp_three = <<-MANIFEST
        file { '/tmp/grant_spec_table.sql':
          ensure  => file,
          content => 'CREATE TABLE grant_spec_table (id int);',
          before  => Mysql::Db['grant_spec_db'],
        }
        mysql::db { 'grant_spec_db':
          user     => 'root1',
          password => 'password',
          sql      => '/tmp/grant_spec_table.sql',
        }
    MANIFEST
    it 'creates table' do
      apply_manifest(pp_three, catch_failures: true)
    end

    it 'has the table' do
      result = run_shell("mysql -e 'show tables;' grant_spec_db|grep grant_spec_table")
      expect(result.exit_code).to be_zero
    end
  end
end
