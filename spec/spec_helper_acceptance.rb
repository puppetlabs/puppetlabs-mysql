require 'beaker-rspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

UNSUPPORTED_PLATFORMS = [ 'Windows', 'Solaris', 'AIX' ]

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
      # Required for binding tests.
      if fact('osfamily') == 'RedHat'
        version = fact("operatingsystemmajrelease")
        if fact('operatingsystemmajrelease') =~ /7/ || fact('operatingsystem') =~ /Fedora/
          shell("yum install -y bzip2")
        end
      end

      # Solaris 11 doesn't ship the SSL CA root for the forgeapi server
      # therefore we need to use a different way to deploy the module to
      # the host
      if host['platform'] =~ /solaris-11/i
        apply_manifest_on(host, 'package { "git": }')
        # PE 3.x and 2015.2 require different locations to install modules
        modulepath = host.puppet['modulepath']
        modulepath = modulepath.split(':').first if modulepath

        environmentpath = host.puppet['environmentpath']
        environmentpath = environmentpath.split(':').first if environmentpath

        destdir = modulepath || "#{environmentpath}/production/modules"
        on host, "git clone https://github.com/puppetlabs/puppetlabs-stdlib #{destdir}/stdlib && cd #{destdir}/stdlib && git checkout 3.2.0"
        on host, "git clone https://github.com/stahnma/puppet-module-epel.git #{destdir}/epel && cd #{destdir}/epel && git checkout 1.0.2"
      else
        on host, puppet('module','install','puppetlabs-stdlib','--version','3.2.0')
        on host, puppet('module','install','stahnma/epel')
      end
    end
  end
end
