require File.expand_path(File.join(File.dirname(__FILE__), '..', 'mysql'))
Puppet::Type.type(:mysql_datadir).provide(:mysql, :parent => Puppet::Provider::Mysql) do

  desc 'manage data directories for mysql instances'

  initvars

  # Make sure we find mysqld on CentOS and mysql_install_db on Gentoo
  ENV['PATH']=ENV['PATH'] + ':/usr/libexec:/usr/share/mysql/scripts:/opt/rh/mysql55/root/usr/bin:/opt/rh/mysql55/root/usr/libexec'

  commands :mysqld => 'mysqld'
  commands :mysql_install_db => 'mysql_install_db'

  def create
    name                     = @resource[:name]
    insecure                 = @resource.value(:insecure) || true
    defaults_extra_file      = @resource.value(:defaults_extra_file)
    user                     = @resource.value(:user) || "mysql"
    basedir                  = @resource.value(:basedir) || "/usr"
    datadir                  = @resource.value(:datadir) || @resource[:name]
    log_error                = @resource.value(:log_error) || "/var/tmp/mysqld_initialize.log"

    unless defaults_extra_file.nil?
      if File.exist?(defaults_extra_file)
        defaults_extra_file="--defaults-extra-file=#{defaults_extra_file}"
      else
        raise ArgumentError, "Defaults-extra-file #{defaults_extra_file} is missing"
      end
    end

    if insecure == true
      initialize="--initialize-insecure"
    else
      initialize="--initialize"
    end

    if mysqld_version.nil?
      debug("Installing MySQL data directory with mysql_install_db #{defaults_extra_file} --basedir=#{basedir} --datadir=#{datadir} --user=#{user}")
      mysql_install_db([defaults_extra_file, "--basedir=#{basedir}", "--datadir=#{datadir}", "--user=#{user}"].compact)
    else
      if (mysqld_type == "mysql" or mysqld_type == "percona") and Puppet::Util::Package.versioncmp(mysqld_version, '5.7.6') >= 0
        debug("Initializing MySQL data directory >= 5.7.6 with 'mysqld #{defaults_extra_file} #{initialize} --basedir=#{basedir} --datadir=#{datadir} --user=#{user}'")
        mysqld([defaults_extra_file, initialize, "--basedir=#{basedir}", "--datadir=#{datadir}", "--user=#{user}", "--log-error=#{log_error}"].compact)
      else
        debug("Installing MySQL data directory with mysql_install_db #{defaults_extra_file} --basedir=#{basedir} --datadir=#{datadir} --user=#{user}")
        mysql_install_db([defaults_extra_file, "--basedir=#{basedir}", "--datadir=#{datadir}", "--user=#{user}"].compact)
      end
    end

   exists?
  end

  def destroy
    name = @resource[:name]
    raise ArgumentError, "ERROR: Resource can not be removed"
  end

  def exists?
    datadir = @resource[:datadir]
    (File.directory?("#{datadir}/mysql")) && (Dir.entries("#{datadir}/mysql") - %w{ . .. }).any? 
  end

  ##
  ## MySQL datadir properties
  ##

  # Generates method for all properties of the property_hash
  mk_resource_methods

end

