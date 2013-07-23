require 'spec_helper_system'

describe 'mysql class' do
  case node.facts['osfamily']
  when 'RedHat'
    package_name = 'mysql-server'
    service_name = 'mysqld'
  when 'Suse'
    package_name = 'mysql-community-server'
    service_name = 'mysql'
  when 'Debian'
    package_name = 'mysql-server'
    service_name = 'mysql'
  end

  describe 'running puppet code' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'mysql::server': }
      EOS

      # Run it twice and test for idempotency
      puppet_apply(pp) do |r|
        r.exit_code.should_not == 1
        r.refresh
        r.exit_code.should be_zero
      end
    end
  end

  describe package(package_name) do
    it { should be_installed }
  end

  describe service(service_name) do
    it { should be_running }
    it { should be_enabled }
  end
end
