require 'spec_helper_acceptance'

describe 'mysql_login_path' do
  describe 'setup' do
    pp = <<-MANIFEST
      yumrepo { 'repo.mysql.com':
        descr    => 'repo.mysql.com',
        baseurl  => 'http://repo.mysql.com/yum/mysql-5.6-community/el/#{host_inventory['facter']['os']['release']['major']}/$basearch/',
        gpgkey   => 'http://repo.mysql.com/RPM-GPG-KEY-mysql',
        enabled  => 1,
        gpgcheck => 1,
      }
      class { '::mysql::server':
        service_manage => false,
        service_name   => 'mysqld',
        package_name   => 'mysql-community-server',
      }
      class {'::mysql::client':
        package_name => 'mysql-community-client',
      }
      user { 'loginpath_test':
        ensure => present,
      }
      Yumrepo['repo.mysql.com']->Class['::mysql::server']
      Yumrepo['repo.mysql.com']->Class['::mysql::client']
    MANIFEST
    it 'works with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'login path for user root' do
    describe 'add login path' do
      pp = <<-MANIFEST
        mysql_login_path { 'local_socket':
          owner    => root,
          host     => 'localhost',
          user     => 'root',
          password => Sensitive('secure'),
          socket   => '/var/run/mysql/mysql.sock',
          ensure   => present,
        }
        mysql_login_path { 'local_tcp':
          owner    => root,
          host     => '127.0.0.1',
          user     => 'network',
          password => Sensitive('more_secure'),
          port     => 3306,
          ensure   => present,
        }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end
      it 'finds the login path #stdout' do
        run_shell("mysql_config_editor print --all") do |r|
          expect(r.stdout).to match(%r{^\[local_socket\]\n})
          expect(r.stdout).to match(%r{host = localhost\n})
          expect(r.stdout).to match(%r{user = root\n})
          expect(r.stdout).to match(%r{socket = /var/run/mysql/mysql.sock\n})

          expect(r.stdout).to match(%r{^\[local_tcp\]\n})
          expect(r.stdout).to match(%r{host = 127.0.0.1\n})
          expect(r.stdout).to match(%r{user = network\n})
          expect(r.stdout).to match(%r{port = 3306\n})
          expect(r.stderr).to be_empty
        end
      end
      it 'finds the login path password #stdout' do
        run_shell("my_print_defaults -s local_socket") do |r|
          expect(r.stdout).to match(%r{--password=secure\n})
        end
        run_shell("my_print_defaults -s local_tcp") do |r|
          expect(r.stdout).to match(%r{--password=more_secure\n})
        end
      end
    end

    describe 'update login path' do
      pp = <<-MANIFEST
        mysql_login_path { 'local_tcp-root':
          owner    => root,
          host     => '10.0.0.1',
          user     => 'network2',
          password => Sensitive('Fort_kn0X'),
          port     => 3307,
          ensure   => present,
        }
      MANIFEST
      pp2 = <<-MANIFEST
        mysql_login_path { 'local_tcp-root':
          ensure  => present,
          host    => '192.168.0.1'
        }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end
      it 'finds the login path #stdout' do
        run_shell("mysql_config_editor print -G local_tcp") do |r|
          expect(r.stdout).to match(%r{^\[local_tcp\]\n})
          expect(r.stdout).to match(%r{host = 10.0.0.1\n})
          expect(r.stdout).to match(%r{user = network2\n})
          expect(r.stdout).to match(%r{port = 3307\n})
          expect(r.stderr).to be_empty
        end
      end
      it 'finds the login path password #stdout' do
        run_shell("my_print_defaults -s local_tcp") do |r|
          expect(r.stdout).to match(%r{--password=Fort_kn0X\n})
        end
      end

      it 'it applies idempotent' do
        idempotent_apply(pp)
      end

      it 'removes values' do
        apply_manifest(pp2, catch_failures: true)
      end
      it 'ensure values are removed #stdout' do
        run_shell("mysql_config_editor print -G local_tcp") do |r|
          expect(r.stdout).to match(%r{^\[local_tcp\]\n})
          expect(r.stdout).to match(%r{host = 192.168.0.1\n})
          expect(r.stdout).not_to match(%r{host = 10.0.0.1\n})
          expect(r.stdout).not_to match(%r{user = network2\n})
          expect(r.stdout).not_to match(%r{port = 3307\n})
          expect(r.stderr).to be_empty
        end
      end
      it 'ensure password removed from the login path #stdout' do
        run_shell("my_print_defaults -s local_tcp") do |r|
          expect(r.stdout).not_to match(%r{--password=Fort_kn0X\n})
        end
      end
    end

    describe 'delete login path' do
      pp = <<-MANIFEST
        mysql_login_path { 'local_socket':
          owner  => root,
          ensure => absent,
        }
        mysql_login_path { 'local_tcp-root':
          ensure => absent,
        }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end
      it 'finds the login path #stdout' do
        run_shell("mysql_config_editor print --all") do |r|
          expect(r.stdout).not_to match(%r{^\[local_socket\]\n})
          expect(r.stdout).not_to match(%r{^\[local_tcp\]\n})
          expect(r.stderr).to be_empty
        end
      end
    end
  end

  context 'login path for user loginpath_test' do
    describe 'add login path' do
      pp = <<-MANIFEST
        mysql_login_path { 'local_tcp':
          owner    => loginpath_test,
          host     => '10.0.0.2',
          user     => 'other',
          password => Sensitive('sensitive'),
          port     => 3306,
          ensure   => present,
        }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end
      it 'finds the login path #stdout' do
        run_shell("MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf mysql_config_editor print -G local_tcp") do |r|
          expect(r.stdout).to match(%r{^\[local_tcp\]\n})
          expect(r.stdout).to match(%r{host = 10.0.0.2\n})
          expect(r.stdout).to match(%r{user = other\n})
          expect(r.stdout).to match(%r{port = 3306\n})
          expect(r.stderr).to be_empty
        end
      end
      it 'finds the login path password #stdout' do
        run_shell("MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf my_print_defaults print -s local_tcp") do |r|
          expect(r.stdout).to match(%r{--password=sensitive\n})
        end
      end
    end

    describe 'update login path' do
      pp = <<-MANIFEST
        mysql_login_path { 'local_tcp-loginpath_test':
          host     => '10.0.0.3',
          user     => 'other2',
          password => Sensitive('password'),
          port     => 3307,
          ensure   => present,
        }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end
      it 'finds the login path #stdout' do
        run_shell("MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf mysql_config_editor print -G local_tcp") do |r|
          expect(r.stdout).to match(%r{^\[local_tcp\]\n})
          expect(r.stdout).to match(%r{host = 10.0.0.3\n})
          expect(r.stdout).to match(%r{user = other2\n})
          expect(r.stdout).to match(%r{port = 3307\n})
          expect(r.stderr).to be_empty
        end
      end
      it 'finds the login path password #stdout' do
        run_shell("MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf my_print_defaults -s local_tcp") do |r|
          expect(r.stdout).to match(%r{--password=password\n})
        end
      end
    end

    describe 'delete login path' do
      pp = <<-MANIFEST
        mysql_login_path { 'local_tcp':
          owner  => loginpath_test,
          ensure => absent,
        }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end
      it 'finds the login path #stdout' do
        run_shell("MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf mysql_config_editor print --all") do |r|
          expect(r.stdout).not_to match(%r{^\[local_tcp\]\n})
          expect(r.stderr).to be_empty
        end
      end
    end
  end

end