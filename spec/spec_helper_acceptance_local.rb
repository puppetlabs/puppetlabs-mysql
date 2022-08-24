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
    LitmusHelper.instance.apply_manifest('include mysql::server', debug: true, catch_failures: true)
    shell_output = LitmusHelper.instance.run_shell('mysql --version')
    raise _('unable to get mysql version') if shell_output.stdout.match(%r{\d+\.\d+\.\d+}).nil?
  end
  mysql_version = shell_output.stdout.match(%r{\d+\.\d+\.\d+})[0]
  mysql_version
end

def export_locales
  LitmusHelper.instance.run_shell('echo export PATH="/opt/puppetlabs/bin:$PATH" > ~/.bashrc')
  LitmusHelper.instance.run_shell('echo export LC_ALL="C" > /etc/profile.d/my-custom.lang.sh')
  LitmusHelper.instance.run_shell('echo "## US English ##" >> /etc/profile.d/my-custom.lang.sh')
  LitmusHelper.instance.run_shell('echo export LANG=en_US.UTF-8 >> /etc/profile.d/my-custom.lang.sh')
  LitmusHelper.instance.run_shell('echo export LANGUAGE=en_US.UTF-8 >> /etc/profile.d/my-custom.lang.sh')
  LitmusHelper.instance.run_shell('echo export LC_COLLATE=C >> /etc/profile.d/my-custom.lang.sh')
  LitmusHelper.instance.run_shell('echo export LC_CTYPE=en_US.UTF-8 >> /etc/profile.d/my-custom.lang.sh')
  LitmusHelper.instance.run_shell('. /etc/profile.d/my-custom.lang.sh')
  LitmusHelper.instance.run_shell('echo export LC_ALL="C" >> ~/.bashrc')
  LitmusHelper.instance.run_shell('. ~/.bashrc')
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

def fetch_charset
  @charset ||= ubuntu_2204? || sles_15? ? 'utf8mb3' : 'utf8'
end

RSpec.configure do |c|
  c.before :suite do
    if os[:family] == 'debian' || os[:family] == 'ubuntu'
      # needed for the puppet fact
      LitmusHelper.instance.apply_manifest("package { 'lsb-release': ensure => installed, }", expect_failures: false)
      LitmusHelper.instance.apply_manifest("package { 'ap': ensure => installed, }", expect_failures: false)

      # Disable the mysqld apparmor profile on Ubuntu and debian
      # exec('mkdir', '/etc/apparmor.d/disable')
      exec('ln', '-s', '/etc/apparmor.d/usr.sbin.mysqld', '/etc/apparmor.d/disable/')
      exec('apparmor_parser', '-R', '/etc/apparmor.d/disable/usr.sbin.mysqld')

    end
    # needed for the grant tests, not installed on el7 docker images
    LitmusHelper.instance.apply_manifest("package { 'which': ensure => installed, }", expect_failures: false)
  end
end
