require 'spec_helper_acceptance'

RSpec.configure do |c|
  c.before(:each) do
    Puppet::Util::Log.level = :debug
    Puppet::Util::Log.newdestination(:console)
  end
end

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

      class {'::mysql::client':
        package_name => 'mysql-community-client',
      }
    MANIFEST
    it 'works with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'create login path with socket' do
    describe 'add login path' do
      pp = <<-MANIFEST
        mysql_login_path { 'local_socket':
          owner    => root,
          host     => 'localhost',
          user     => 'root',
          password => 'secure',
          socket   => '/var/run/mysql/mysql.sock',
          ensure   => present,
        }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      #it 'finds the login path #stdout' do
      #  run_shell("mysql_config_editor print -G local_socket") do |r|
      #    expect(r.stdout).to match(%r{^\[local_socket\]\n})
      #    expect(r.stdout).to match(%r{user = root\n})
      #    expect(r.stdout).to match(%r{password = \*{5}\n})
      #    expect(r.stdout).to match(%r{host = localhost\n})
      #    expect(r.stderr).to be_empty
      #  end
      #end

    end
  end

  #context 'create login path with socket' do
  #  describe 'add login path' do
  #    pp = <<-MANIFEST
  #      mysql_login_path { 'local_socket':
  #        host => 'localhost',
  #        user => 'root',
  #        password => 'secure',
  #        socket => '/var/run/mysql/mysql.sock',
  #        ensure => present,
  #      }
  #    MANIFEST
  #    it 'works without errors' do
  #      apply_manifest(pp, catch_failures: true)
  #    end
  #
  #    it 'finds the login path #stdout' do
  #      run_shell("mysql_config_editor print -G local_socket") do |r|
  #        expect(r.stdout).to match(%r{^1$})
  #        expect(r.stderr).to be_empty
  #      end
  #    end
  #  end
  #end

end