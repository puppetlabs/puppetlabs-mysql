require 'puppet'
require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'beaker/i18n_helper'

run_puppet_install_helper
install_ca_certs unless ENV['PUPPET_INSTALL_TYPE'] =~ %r{pe}i
install_module_on(hosts)
install_module_dependencies_on(hosts)

UNSUPPORTED_PLATFORMS = %w[Windows Solaris AIX].freeze

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # detect the situation where PUP-5016 is triggered and skip the idempotency tests in that case
  # also note how fact('puppetversion') is not available because of PUP-4359
  if fact('osfamily') == 'Debian' && fact('operatingsystemmajrelease') == '8' && shell('puppet --version').stdout =~ %r{^4\.2}
    c.filter_run_excluding skip_pup_5016: true
  end

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      # This will be removed, this is temporary to test localisation.
      if fact('osfamily') == 'Debian'
        # install language pack on debian systems
        install_language_pack(host, 'ja_JP')
        # This will be removed, this is temporary to test localisation.
        on(host, 'sudo mkdir /opt/puppetlabs/puppet/share/locale/ja')
        on(host, 'sudo touch /opt/puppetlabs/puppet/share/locale/ja/puppet.po')
      end
      # Required for binding tests.
      if fact('osfamily') == 'RedHat'
        if fact('operatingsystemmajrelease') =~ %r{7} || fact('operatingsystem') =~ %r{Fedora}
          shell('yum install -y bzip2')
        end
      end

      on host, puppet('module', 'install', 'stahnma/epel')
    end
  end
end

shared_examples 'a idempotent resource' do
  it 'applies with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'applies a second time without changes', :skip_pup_5016 do
    apply_manifest(pp, catch_changes: true)
  end
end
