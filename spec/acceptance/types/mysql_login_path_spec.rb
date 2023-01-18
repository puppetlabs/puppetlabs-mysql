# frozen_string_literal: true

require 'spec_helper_acceptance'

mysql_version = '5.6'
support_bin_dir = '/root/mysql_login_path'
if os[:family] == 'redhat' && os[:release].to_i == 8
  mysql_version = '8.0'
elsif os[:family] == 'debian' && os[:release] =~ %r{9|10|11}
  mysql_version = '8.0'
elsif os[:family] == 'ubuntu' && os[:release] =~ %r{18\.04|20\.04}
  mysql_version = '5.7'
end

describe 'mysql_login_path', unless: "#{os[:family]}-#{os[:release].to_i}".include?('suse') do
  before(:all) do
    run_shell("rm -rf #{support_bin_dir}")
    bolt_upload_file('spec/support/mysql_login_path', support_bin_dir)
    run_shell("cp #{support_bin_dir}/mysql-#{mysql_version}/my_print_defaults /usr/bin/.")
    run_shell("cp #{support_bin_dir}/mysql-#{mysql_version}/mysql_config_editor /usr/bin/.")
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
    run_shell("rm -rf #{support_bin_dir}")
  end

  describe 'setup' do
    pp = <<-MANIFEST
      user { 'loginpath_test':
        ensure => present,
        managehome => true,
      }
    MANIFEST
    it 'works with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
    it 'finds mysql_config_editor binary for the provider' do
      run_shell('mysql_config_editor -V') do |r|
        expect(r.stdout).to match(%r{Ver.*#{mysql_version}.*x86_64})
      end
    end
    it 'finds my_print_defaults binary for the provider' do
      run_shell('my_print_defaults -V') do |r|
        expect(r.exit_status).to eq(0)
      end
    end
  end

  context 'for user root' do
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
        run_shell('mysql_config_editor print --all') do |r|
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
        run_shell('my_print_defaults -s local_socket') do |r|
          expect(r.stdout).to match(%r{--password=secure\n})
        end
        run_shell('my_print_defaults -s local_tcp') do |r|
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
        run_shell('mysql_config_editor print -G local_tcp') do |r|
          expect(r.stdout).to match(%r{^\[local_tcp\]\n})
          expect(r.stdout).to match(%r{host = 10.0.0.1\n})
          expect(r.stdout).to match(%r{user = network2\n})
          expect(r.stdout).to match(%r{port = 3307\n})
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
          expect(r.stdout).to match(%r{^\[local_tcp\]\n})
          expect(r.stdout).to match(%r{host = 192.168.0.1\n})
          expect(r.stdout).not_to match(%r{host = 10.0.0.1\n})
          expect(r.stdout).not_to match(%r{user = network2\n})
          expect(r.stdout).not_to match(%r{port = 3307\n})
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
        run_shell('MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf mysql_config_editor print -G local_tcp') do |r|
          expect(r.stdout).to match(%r{^\[local_tcp\]\n})
          expect(r.stdout).to match(%r{host = 10.0.0.2\n})
          expect(r.stdout).to match(%r{user = other\n})
          expect(r.stdout).to match(%r{port = 3306\n})
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
        run_shell('MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf mysql_config_editor print -G local_tcp') do |r|
          expect(r.stdout).to match(%r{^\[local_tcp\]\n})
          expect(r.stdout).to match(%r{host = 10.0.0.3\n})
          expect(r.stdout).to match(%r{user = other2\n})
          expect(r.stdout).to match(%r{port = 3307\n})
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
        run_shell('MYSQL_TEST_LOGIN_FILE=/home/loginpath_test/.mylogin.cnf mysql_config_editor print --all') do |r|
          expect(r.stdout).not_to match(%r{^\[local_tcp\]\n})
          expect(r.stderr).to be_empty
        end
      end
    end
  end
end
