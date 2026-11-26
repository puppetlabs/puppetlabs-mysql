# frozen_string_literal: true

require 'etc'
require 'fileutils'
require 'puppet/util/selinux'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'mysql'))
Puppet::Type.type(:mysql_datadir).provide(:mysql, parent: Puppet::Provider::Mysql) do
  desc 'manage data directories for mysql instances'

  include Puppet::Util::SELinux

  initvars

  # Make sure we find mysqld on CentOS and mysql_install_db on Gentoo and Solaris 11
  ENV['PATH'] = [
    ENV.fetch('PATH', nil),
    '/usr/libexec',
    '/usr/share/mysql/scripts',
    '/opt/rh/rh-mysql80/root/usr/bin',
    '/opt/rh/rh-mysql80/root/usr/libexec',
    '/opt/rh/rh-mysql57/root/usr/bin',
    '/opt/rh/rh-mysql57/root/usr/libexec',
    '/opt/rh/rh-mysql56/root/usr/bin',
    '/opt/rh/rh-mysql56/root/usr/libexec',
    '/opt/rh/rh-mariadb101/root/usr/bin',
    '/opt/rh/rh-mariadb101/root/usr/libexec',
    '/opt/rh/rh-mariadb100/root/usr/bin',
    '/opt/rh/rh-mariadb100/root/usr/libexec',
    '/opt/rh/rh-mariadb102/root/usr/bin',
    '/opt/rh/rh-mariadb102/root/usr/libexec',
    '/opt/rh/rh-mariadb103/root/usr/bin',
    '/opt/rh/rh-mariadb103/root/usr/libexec',
    '/opt/rh/mysql55/root/usr/bin',
    '/opt/rh/mysql55/root/usr/libexec',
    '/opt/rh/mariadb55/root/usr/bin',
    '/opt/rh/mariadb55/root/usr/libexec',
    '/usr/mysql/5.5/bin',
    '/usr/mysql/5.6/bin',
    '/usr/mysql/5.7/bin',
  ].join(':')

  superclass::COMMANDS[:mysqld].each_with_index do |binary_name, idx|
    optional_commands "mysqld#{idx}": binary_name
  end
  confine true: -> { superclass::COMMANDS[:mysqld].any? { |binary_name| Puppet::Util.which(binary_name) } }
  optional_commands mysql_install_db: 'mysql_install_db'
  # rubocop:disable Lint/UselessAssignment
  def create
    name                     = @resource[:name]
    insecure                 = @resource.value(:insecure) || true
    defaults_extra_file      = @resource.value(:defaults_extra_file)
    user                     = @resource.value(:user) || 'mysql'
    basedir                  = @resource.value(:basedir)
    datadir                  = @resource.value(:datadir) || @resource[:name]
    log_error                = @resource.value(:log_error) || '/var/tmp/mysqld_initialize.log'
    # rubocop:enable Lint/UselessAssignment
    unless defaults_extra_file.nil?
      raise ArgumentError, _('Defaults-extra-file %{file} is missing.') % { file: defaults_extra_file } unless File.exist?(defaults_extra_file)

      defaults_extra_file = "--defaults-extra-file=#{defaults_extra_file}"
    end

    initialize = if insecure == true
                   '--initialize-insecure'
                 else
                   '--initialize'
                 end

    opts = [defaults_extra_file]
    ['basedir', 'datadir'].each do |opt|
      val = eval(opt) # rubocop:disable Security/Eval
      opts << "--#{opt}=#{val}" unless val.nil?
    end

    pw = Etc.getpwnam(user)
    missing_datadir = !File.directory?(datadir)
    # A missing datadir: root created it before, the user cannot create it in e.g. /var/lib.
    FileUtils.mkdir_p(datadir, mode: 0o750) if missing_datadir
    if missing_datadir || File.stat(datadir).uid != pw.uid
      FileUtils.chown(pw.uid, pw.gid, datadir)
      set_selinux_default_context(datadir, :directory)
    end

    if !mysqld_version.nil? && newer_than('mysql' => '5.7.6', 'percona' => '5.7.6')
      opts << "--log-error=#{log_error}"
      opts << initialize.to_s
      debug("Initializing MySQL data directory >= 5.7.6 with mysqld as #{user}: #{opts.compact.join(' ')}")
      binary = Puppet::Provider::Mysql::COMMANDS[:mysqld].filter_map { |b| Puppet::Util.which(b) }.first
      raise Puppet::MissingCommand, _('Command mysqld is missing') if binary.nil?
    else
      debug("Installing MySQL data directory with mysql_install_db as #{user}: #{opts.compact.join(' ')}")
      binary = command(:mysql_install_db)
      raise Puppet::MissingCommand, _('Command mysql_install_db is missing') if binary.nil?
    end

    # Run as the user instead of passing --user: mysqld as root would have to switch the user and
    # override permissions, which SELinux does not allow mysqld_t (e.g. MariaDB on EL9).
    execute(
      [binary] + opts.compact,
      uid: user,
      gid: pw.gid,
      cwd: '/',
      custom_environment: { 'HOME' => pw.dir, 'USER' => pw.name },
      failonfail: true,
      combine: true,
    )

    exists?
  end

  def destroy
    name = @resource[:name] # rubocop:disable Lint/UselessAssignment
    raise ArgumentError, _('ERROR: `Resource` can not be removed.')
  end

  def exists?
    datadir = @resource[:datadir]
    File.directory?("#{datadir}/mysql") && (Dir.entries("#{datadir}/mysql") - ['.', '..']).any?
  end

  ##
  ## MySQL datadir properties
  ##

  # Generates method for all properties of the property_hash
  mk_resource_methods
end
