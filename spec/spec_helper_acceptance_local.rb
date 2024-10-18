# frozen_string_literal: true

require 'singleton'

class LitmusHelper
  include Singleton
  include PuppetLitmus
end

def mysql_version
  shell_output = LitmusHelper.instance.run_shell('mysql --version', expect_failures: true)
  if shell_output.stdout.match(%r{\d+\.\d+\.\d+}).nil?
    # mysql is not yet installed, so we apply this class to install it
    LitmusHelper.instance.apply_manifest('include mysql::server', catch_failures: true)
    shell_output = LitmusHelper.instance.run_shell('mysql --version')
    raise _('unable to get mysql version') if shell_output.stdout.match(%r{\d+\.\d+\.\d+}).nil?
  end
  shell_output.stdout.match(%r{\d+\.\d+\.\d+})[0]
end

def supports_xtrabackup?
  (os[:family] == 'redhat' && os[:release].to_i > 7) ||
    os[:family] == 'debian' ||
    os[:family] == 'ubuntu'
end

def redhat_9?
  os[:family] == 'redhat' && os[:release].to_i == 9
end

def ubuntu_2204?
  os[:family] == 'ubuntu' && os[:release].to_f == 22.04
end

def sles_15?
  os[:family] == 'sles' && os[:release].to_i == 15
end

def debian_12?
  os[:family] == 'debian' && os[:release].to_i == 12
end

def charset
  @charset ||= (debian_12? || ubuntu_2204? || sles_15?) ? 'utf8mb3' : 'utf8'
end

RSpec.configure do |c|
  c.before :suite do
    if os[:family] == 'debian' || os[:family] == 'ubuntu'
      # needed for the puppet fact
      LitmusHelper.instance.apply_manifest("package { 'lsb-release': ensure => installed, }", expect_failures: false)
      LitmusHelper.instance.apply_manifest("package { 'ap': ensure => installed, }", expect_failures: false)
    end
    # needed for the grant tests, not installed on el7 docker images
    LitmusHelper.instance.apply_manifest("package { 'which': ensure => installed, }", expect_failures: false)
  end
end
