# frozen_string_literal: true

require 'singleton'

class LitmusHelper
  include Singleton
  include PuppetLitmus
end

# TEMPORARY FIX for unregistered SLES CI systems with no repos configured.
# Configures openSUSE Leap and MariaDB repos to enable package installation.
# DO NOT use in production - not enterprise-supported.
def configure_sles_repos_once
  return if @sles_repos_configured || os[:family] != 'sles'

  sles_version = os[:release].to_i
  base_url = (sles_version == 12) ? 'http://download.opensuse.org/distribution/leap/42.3/repo' : 'http://download.opensuse.org/distribution/leap/15.6/repo'
  mariadb_version = (sles_version == 12) ? '10.6' : '10.11'

  run_shell("zypper --non-interactive --gpg-auto-import-keys ar #{base_url}/oss/ opensuse-leap-oss || true", expect_failures: true)
  run_shell("zypper --non-interactive --gpg-auto-import-keys ar #{base_url}/non-oss/ opensuse-leap-non-oss || true", expect_failures: true)
  run_shell('rpm --import https://supplychain.mariadb.com/MariaDB-Server-GPG-KEY', expect_failures: true)
  run_shell("zypper --non-interactive --gpg-auto-import-keys ar https://rpm.mariadb.org/#{mariadb_version}/sles/#{sles_version}/x86_64 mariadb || true", expect_failures: true)
  run_shell('zypper --non-interactive --gpg-auto-import-keys refresh', expect_failures: false)
  LitmusHelper.instance.apply_manifest("package { 'net-tools-deprecated': ensure => 'latest', }", expect_failures: false)

  @sles_repos_configured = true
end

def mysql_version
  configure_sles_repos_once

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

def get_db_cmd
  run_shell('mariadb -V', expect_failures: true).stdout.empty? ? 'mysql' : 'mariadb'
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
