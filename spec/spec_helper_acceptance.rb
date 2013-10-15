require 'beaker-rspec'

hosts.each do |host|
  # Install Puppet
  install_package host, 'rubygems'
  on host, 'gem install puppet --no-ri --no-rdoc'
  on host, "mkdir -p #{host['distmoduledir']}"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'mysql')
    hosts.each do |host|
      shell('/bin/touch /etc/puppet/hiera.yaml')
      shell('puppet module install puppetlabs-stdlib --version 2.2.1', { :acceptable_exit_codes => [0,1] })
    end
  end
end
