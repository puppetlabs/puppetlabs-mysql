require 'puppet'
require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper
install_ca_certs unless ENV['PUPPET_INSTALL_TYPE'] =~ /pe/i
install_module_on(hosts)
install_module_dependencies_on(hosts)

UNSUPPORTED_PLATFORMS = ['Windows', 'Solaris', 'AIX']

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # detect the situation where PUP-5016 is triggered and skip the idempotency tests in that case
  # also note how fact('puppetversion') is not available because of PUP-4359
  if fact('osfamily') == 'Debian' && fact('operatingsystemmajrelease') == '8' && shell('puppet --version').stdout =~ /^4\.2/
    c.filter_run_excluding :skip_pup_5016 => true
  end

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      # Required for binding tests.
      if fact('osfamily') == 'RedHat'
        if fact('operatingsystemmajrelease') =~ /7/ || fact('operatingsystem') =~ /Fedora/
          shell("yum install -y bzip2")
        end
      end

      on host, puppet('module', 'install', 'stahnma/epel')
    end
  end
end


shared_examples "a idempotent resource" do
  it 'should apply with no errors' do
    apply_manifest(pp, :catch_failures => true)
  end

  it 'should apply a second time without changes', :skip_pup_5016 do
    apply_manifest(pp, :catch_changes => true)
  end
end
