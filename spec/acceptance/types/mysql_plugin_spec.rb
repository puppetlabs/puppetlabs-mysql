# frozen_string_literal: true

require 'spec_helper_acceptance'

# Different operating systems (and therefore different versions/forks
# of mysql) have varying levels of support for plugins and have
# different plugins available. Choose a plugin that works or don't try
# to test plugins if not available.
case os[:family]
when 'redhat'
  case os[:release].to_i
  when 7
    plugin     = 'pam'
    plugin_lib = 'auth_pam.so'
  end
when 'debian'
  if os[:family] == 'ubuntu'
    if %r{^16\.04|^18\.04}.match?(os[:release])
      # On Xenial running 5.7.12, the example plugin does not appear to be available.
      plugin = 'validate_password'
      plugin_lib = 'validate_password.so'
    else
      plugin     = 'example'
      plugin_lib = 'ha_example.so'
    end
  end
when 'suse'
  plugin = nil # Plugin library path is broken on Suse http://lists.opensuse.org/opensuse-bugs/2013-08/msg01123.html
end

describe 'mysql_plugin' do
  if plugin # if plugins are supported
    describe 'setup' do
      it 'works with no errors' do
        pp = <<-MANIFEST
          class { 'mysql::server': }
        MANIFEST

        apply_manifest(pp, catch_failures: true)
      end
    end

    describe 'load plugin' do
      pp = <<-MANIFEST
          mysql_plugin { #{plugin}:
            ensure => present,
            soname => '#{plugin_lib}',
          }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp, catch_failures: true)
      end

      it 'finds the plugin #stdout' do
        run_shell("mysql -NBe \"select plugin_name from information_schema.plugins where plugin_name='#{plugin}'\"") do |r|
          expect(r.stdout).to match(%r{^#{plugin}$}i)
          expect(r.stderr).to be_empty
        end
      end
    end
  end
end
