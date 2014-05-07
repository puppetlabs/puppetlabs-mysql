require 'spec_helper_acceptance'

describe 'config location', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  it 'creates the file elsewhere' do
    pp = <<-EOS
        class { 'mysql::server':
          config_file => '/etc/testmy.cnf',
        }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  describe file('/etc/testmy.cnf') do
    it { should be_file }
  end
end

describe 'manage_config_file' do
  it 'wont reset the location of my.cnf' do
    pp = <<-EOS
      class { 'mysql::server':
        config_file        => '/etc/my.cnf',
        manage_config_file => false,
        service_manage     => false,
      }
    EOS
    # Make sure this doesn't exist so we can test if puppet
    # readded it.  It may not exist in the first place on
    # some platforms.
    shell('rm /etc/my.cnf', :acceptable_exit_codes => [0,1,2])
    apply_manifest(pp, :catch_failures => true)
  end

  describe file('/etc/my.cnf') do
    it { should_not be_file }
  end
end

describe 'includedir location', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  it 'creates the file elsewhere' do
    pp = <<-EOS
        class { 'mysql::server':
          includedir => '/etc/my.cnf.d',
          config_file => '/etc/testmy.cnf',
        }
    EOS
    # Make sure this doesn't exist so we can test if puppet
    # readded it.  It may not exist in the first place on
    # some platforms.
    shell('rmdir /etc/my.cnf.d', :acceptable_exit_codes => [0,1,2])
    apply_manifest(pp, :catch_failures => true)
  end

  describe file('/etc/my.cnf.d') do
    it { should be_directory }
  end

  describe file('/etc/testmy.cnf') do
    it { sould contain "!includedir /etc/my.cnf.d" }
  end
end

describe 'no includedir location', :unless => UNSUPPORTED_PLATFORMS.include?(fact('operatingsystem')) do
  it 'creates the file elsewhere' do
    pp = <<-EOS
        class { 'mysql::server':
          includedir => '',
          config_file => '/etc/testmy.cnf',
        }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  describe file('/etc/testmy.cnf') do
    it { should_not contain "includedir" }
  end
end


describe 'resets' do
  it 'cleans up' do
    pp = <<-EOS
        class { 'mysql::server': }
    EOS
    apply_manifest(pp, :catch_failures => true)
    shell('rm /etc/testmy.cnf')
  end
end

