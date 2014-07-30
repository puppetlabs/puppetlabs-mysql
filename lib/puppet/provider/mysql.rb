require 'puppet/util/package'

class Puppet::Provider::Mysql < Puppet::Provider

  # Without initvars commands won't work.
  initvars
  commands :mysql      => 'mysql'
  commands :mysqladmin => 'mysqladmin'

  # if we actually *can* find mysql in the path, we check the version, and
  # based on that, we check if the passed version is >= the product_version
  def self.version_check(version)
    begin
      # mysql --version # for mysql and mariadb
      # =#> mysql  Ver 14.14 Distrib 5.5.37, for debian-linux-gnu (x86_64) using readline 6.2
      # =#> mysql  Ver 15.1 Distrib 10.0.12-MariaDB, for debian-linux-gnu (x86_64) using readline 5.1

      product_version = mysql('--version').split[4].chop
    rescue Puppet::ExecutionFailure
      false
    else
      true if Puppet::Util::Package.versioncmp(product_version, version) >= 0
    end
  end

  # Optional defaults file
  def self.defaults_file
    if File.file?("#{Facter.value(:root_home)}/.my.cnf")
      "--defaults-extra-file=#{Facter.value(:root_home)}/.my.cnf"
    else
      nil
    end
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
