# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'mysql_login_path' do
  begin
    # mysql_config_editor is not supported on mariadb
    # all tests should be skipped
    run_shell('mysql_config_editor -V')
  rescue
    return
  end

  let(:base_pp) do
    <<-MANIFEST
      user { 'loginpath_test':
        ensure => present,
        managehome => true,
      }
    MANIFEST
  end

  after(:all) do
    pp_cleanup = <<-MANIFEST
      user { 'loginpath_test':
        ensure => absent,
      }
      file { '/root/.mylogin.cnf':
        ensure => absent,
      }
    MANIFEST
    apply_manifest(pp_cleanup, catch_failures: true)
  end

  context 'for user root' do
    describe 'add login path' do
      let(:pp) do
        <<-MANIFEST
        #{base_pp}
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
      end

      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the login path #stdout' do
        run_shell('mysql_config_editor print --all') do |r|
          regex_match = [%r{^\[local_socket\]\n}, %r{host = localhost\n}, %r{user = root\n}, %r{socket = /var/run/mysql/mysql.sock\n},
                         %r{^\[local_tcp\]\n}, %r{host = 127.0.0.1\n}, %r{user = network\n}, %r{port = 3306\n}]
          regex_match.each do |reg|
            expect(r.stdout).to match(reg)
          end
          expect(r.stderr).to be_empty
        end
      end

      it 'finds the login path password #stdout' do
        run_shell('my_print_defaults -s local_socket') do |r|
          expect(r.stdout).to match(%r{--password=secure\n})
        end
        run_shell('my_print_defaults -s local_tcp') do |r|
          expect(r.stdout).to match(%r{--password=more_secure\n})
        end
      end
    end

    describe 'update login path' do
      let(:pp) do
        <<-MANIFEST
        #{base_pp}
        mysql_login_path { 'local_tcp-root':
          owner    => root,
          host     => '10.0.0.1',
          user     => 'network2',
          password => Sensitive('Fort_kn0X'),
          port     => 3307,
          ensure   => present,
        }
        MANIFEST
      end

      let(:pp2) do
        <<-MANIFEST
        mysql_login_path { 'local_tcp-root':
          ensure  => present,
          host    => '192.168.0.1'
        }
        MANIFEST
      end

      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the login path #stdout' do
        run_shell('mysql_config_editor print -G local_tcp') do |r|
          regex_match = [%r{^\[local_tcp\]\n}, %r{host = 10.0.0.1\n}, %r{user = network2\n}, %r{port = 3307\n}]
          regex_match.each do |reg|
            expect(r.stdout).to match(reg)
          end
          expect(r.stderr).to be_empty
        end
      end

      it 'finds the login path password #stdout' do
        run_shell('my_print_defaults -s local_tcp') do |r|
          expect(r.stdout).to match(%r{--password=Fort_kn0X\n})
        end
      end

      it 'applies idempotent' do
        idempotent_apply(pp)
      end

      it 'removes values' do
        apply_manifest(pp2, catch_failures: true)
      end

      it 'ensure values are removed #stdout' do
        run_shell('mysql_config_editor print -G local_tcp') do |r|
          regex_match = [%r{^\[local_tcp\]\n}, %r{host = 192.168.0.1\n}]
          regex_match.each do |reg|
            expect(r.stdout).to match(reg)
          end
          regex_no_match = [%r{host = 10.0.0.1\n}, %r{user = network2\n}, %r{port = 3307\n}]
          regex_no_match.each do |reg|
            expect(r.stdout).not_to match(reg)
          end
          expect(r.stderr).to be_empty
        end
      end

      it 'ensure password removed from the login path #stdout' do
        run_shell('my_print_defaults -s local_tcp') do |r|
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
        run_shell('mysql_config_editor print --all') do |r|
          expect(r.stdout).not_to match(%r{^\[local_socket\]\n})
          expect(r.stdout).not_to match(%r{^\[local_tcp\]\n})
          expect(r.stderr).to be_empty
        end
      end
    end
  end

  context 'for user loginpath_test' do
    describe 'add login path' do
      let(:pp) do
        <<-MANIFEST
        #{base_pp}
        mysql_login_path { 'local_tcp':
          owner    => loginpath_test,
          host     => '10.0.0.2',
          user     => 'other',
          password => Sensitive('sensitive'),
          port     => 3306,
          ensure   => present,
        }
        MANIFEST
      end

      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the login path #stdout' do
        run_shell('MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf mysql_config_editor print -G local_tcp') do |r|
          regex_match = [%r{^\[local_tcp\]\n}, %r{host = 10.0.0.2\n}, %r{user = other\n}, %r{port = 3306\n}]
          regex_match.each do |reg|
            expect(r.stdout).to match(reg)
          end
          expect(r.stderr).to be_empty
        end
      end

      it 'finds the login path password #stdout' do
        run_shell('MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf my_print_defaults print -s local_tcp') do |r|
          expect(r.stdout).to match(%r{--password=sensitive\n})
        end
      end
    end

    describe 'update login path' do
      let(:pp) do
        <<-MANIFEST
        #{base_pp}
        mysql_login_path { 'local_tcp-loginpath_test':
          host     => '10.0.0.3',
          user     => 'other2',
          password => Sensitive('password'),
          port     => 3307,
          ensure   => present,
        }
        MANIFEST
      end

      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the login path #stdout' do
        run_shell('MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf mysql_config_editor print -G local_tcp') do |r|
          regex_match = [%r{^\[local_tcp\]\n}, %r{host = 10.0.0.3\n}, %r{user = other2\n}, %r{port = 3307\n}]
          regex_match.each do |reg|
            expect(r.stdout).to match(reg)
          end
          expect(r.stderr).to be_empty
        end
      end

      it 'finds the login path password #stdout' do
        run_shell('MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf my_print_defaults -s local_tcp') do |r|
          expect(r.stdout).to match(%r{--password=password\n})
        end
      end
    end

    describe 'delete login path' do
      let(:pp) do
        <<-MANIFEST
        #{base_pp}
        mysql_login_path { 'local_tcp':
          owner  => loginpath_test,
          ensure => absent,
        }
        MANIFEST
      end

      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the login path #stdout' do
        run_shell('MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf mysql_config_editor print --all') do |r|
          expect(r.stdout).not_to match(%r{^\[local_tcp\]\n})
          expect(r.stderr).to be_empty
        end
      end
    end
  end
end
