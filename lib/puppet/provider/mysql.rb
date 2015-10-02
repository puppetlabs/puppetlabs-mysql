class Puppet::Provider::Mysql < Puppet::Provider

  # Without initvars commands won't work.
  initvars
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

  def self.mysql_version_string
    return @mysql_version_string unless @mysql_version_string.nil?
    @mysql_version_string = mysql([defaults_file, '-NBe',
      "SELECT VERSION()"].compact)
  end

  def self.mysql_major
    a,b,c= mysql_version_string.split("\.")
    a.to_i
  end

  def self.mysql_minor
    a,b,c= mysql_version_string.split("\.")
    b.to_i
  end

  def self.mysql_revision
    a,b,c= mysql_version_string.split("\.")
    c.to_i
  end
  
  
  def mysql_major
    self.class.mysql_major
  end

  def mysql_minor
    self.class.mysql_minor
  end

  def mysql_revision
    self.class.mysql_revision
  end

  def defaults_file
    self.class.defaults_file
  end

  def self.users
    mysql([defaults_file, '-NBe', "SELECT CONCAT(User, '@',Host) AS User FROM mysql.user"].compact).split("\n")
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
