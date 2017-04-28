class Puppet::Provider::Mysql < Puppet::Provider

  # Without initvars commands won't work.
  initvars

  # Make sure we find mysql commands on CentOS and FreeBSD
  ENV['PATH']=ENV['PATH'] + ':/usr/libexec:/usr/local/libexec:/usr/local/bin'

  commands :mysql      => 'mysql'
  commands :mysqladmin => 'mysqladmin'

  # Optional defaults file
  def self.defaults_file
    if File.file?("#{Facter.value(:root_home)}/.my.cnf")
      "--defaults-extra-file=#{Facter.value(:root_home)}/.my.cnf"
    else
      nil
    end
  end

  def self.mysqld_type
    Facter.value(:mysqld_type)
  end

  def mysqld_type
    self.class.mysqld_type
  end

  def self.mysqld_version_string
    Facter.value(:mysqld_version_string)
  end

  def mysqld_version_string
    self.class.mysqld_version_string
  end

  def self.mysqld_version
    # As the possibility of the mysqld being remote we need to allow the version
    # to be overridden, this can be done by facter.value as seen below.
    Facter.value(:mysqld_version)
  end

  def mysqld_version
    self.class.mysqld_version
  end

  def defaults_file
    self.class.defaults_file
  end

  def self.users
    mysql([defaults_file, '-NBe', "SELECT CONCAT(User, '@',Host) AS User FROM mysql.user"].compact).split("\n")
  end

  # Optional parameter to run a statement on the MySQL system database.
  def self.system_database
    '--database=mysql'
  end

  def system_database
    self.class.system_database
  end

  # Take root@localhost and munge it to 'root'@'localhost'
  def self.cmd_user(user)
    "'#{user.sub('@', "'@'")}'"
  end

  # Take root.* and return ON `root`.*
  def self.cmd_table(table)
    table_string = ''

    # We can't escape *.* so special case this.
    if table == '*.*'
      table_string << '*.*'
    # Special case also for PROCEDURES
    elsif table.start_with?('PROCEDURE ')
      table_string << table.sub(/^PROCEDURE (.*)(\..*)/, 'PROCEDURE `\1`\2')
    else
      table_string << table.sub(/^(.*)(\..*)/, '`\1`\2')
    end
    table_string
  end

  def self.cmd_privs(privileges)
    if privileges.include?('ALL')
      return 'ALL PRIVILEGES'
    else
      priv_string = ''
      privileges.each do |priv|
        priv_string << "#{priv}, "
      end
    end
    # Remove trailing , from the last element.
    priv_string.sub(/, $/, '')
  end

  # Take in potential options and build up a query string with them.
  def self.cmd_options(options)
    option_string = ''
    options.each do |opt|
      if opt == 'GRANT'
        option_string << ' WITH GRANT OPTION'
      end
    end
    option_string
  end

end
