# frozen_string_literal: true

require 'singleton'

class LitmusHelper
  include Singleton
  include PuppetLitmus
end

def pre_run
  LitmusHelper.instance.apply_manifest("class { 'mysql::server': root_password => 'password' }", catch_failures: true)
end

def mysql_version
  shell_output = LitmusHelper.instance.run_shell('mysql --version', expect_failures: true)
  if shell_output.stdout.match(%r{\d+\.\d+\.\d+}).nil?
    pre_run
    shell_output = LitmusHelper.instance.run_shell('mysql --version')
    raise _('unable to get mysql version') if shell_output.stdout.match(%r{\d+\.\d+\.\d+}).nil?
  end
  mysql_version = shell_output.stdout.match(%r{\d+\.\d+\.\d+})[0]
  mysql_version
end

RSpec.configure do |c|
  c.before :suite do
    if os[:family] == 'debian' || os[:family] == 'ubuntu'
      # needed for the puppet fact
      LitmusHelper.instance.apply_manifest("package { 'lsb-release': ensure => installed, }", expect_failures: false)
      LitmusHelper.instance.apply_manifest("package { 'curl': ensure => installed, }", expect_failures: false)
      LitmusHelper.instance.apply_manifest("package { 'percona-xtrabackup-24': ensure => installed, }", expect_failures: false)
      LitmusHelper.instance.run_shell('apt update', expect_failures: false)
    end
    # needed for the grant tests, not installed on el7 docker images
    LitmusHelper.instance.apply_manifest("package { 'which': ensure => installed, }", expect_failures: false)
  end
end
