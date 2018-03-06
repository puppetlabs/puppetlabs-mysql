# Puppet provider for mysql
class Puppet::Provider::Mysql < Puppet::Provider
  # Without initvars commands won't work.
  initvars

  # Make sure we find mysql commands on CentOS and FreeBSD
  ENV['PATH'] = ENV['PATH'] + ':/usr/libexec:/usr/local/libexec:/usr/local/bin'

  # rubocop:disable Style/HashSyntax
  commands :mysql      => 'mysql'
  commands :mysql_raw  => 'mysql'
  commands :mysqld     => 'mysqld'
  commands :mysqladmin => 'mysqladmin'
  # rubocop:enable Style/HashSyntax

  # Optional defaults file
  def self.defaults_file
    "--defaults-extra-file=#{Facter.value(:root_home)}/.my.cnf" if File.file?("#{Facter.value(:root_home)}/.my.cnf")
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

  def self.mysql_caller(text_of_sql, type)
    if type.eql? 'system'
      mysql_raw([defaults_file, '--host=', system_database, '-e', text_of_sql].flatten.compact)
    elsif type.eql? 'regular'
      mysql_raw([defaults_file, '-NBe', text_of_sql].flatten.compact)
    else
      raise Puppet::Error, _("#mysql_caller: Unrecognised type '%{type}'" % { type: type })
    end
  end

  def self.users
    mysql_caller("SELECT CONCAT(User, '@',Host) AS User FROM mysql.user", 'regular').split("\n")
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
    table_string << if table == '*.*'
                      '*.*'
                    # Special case also for FUNCTIONs and PROCEDUREs
                    elsif table.start_with?('FUNCTION ', 'PROCEDURE ')
                      table.sub(%r{^(FUNCTION|PROCEDURE) (.*)(\..*)}, '\1 `\2`\3')
                    else
                      table.sub(%r{^(.*)(\..*)}, '`\1`\2')
                    end
    table_string
  end

  def self.cmd_privs(privileges)
    return 'ALL PRIVILEGES' if privileges.include?('ALL')
    priv_string = ''
    privileges.each do |priv|
      priv_string << "#{priv}, "
    end
    # Remove trailing , from the last element.
    priv_string.sub(%r{, $}, '')
  end

  # Take in potential options and build up a query string with them.
  def self.cmd_options(options)
    option_string = ''
    options.each do |opt|
      option_string << ' WITH GRANT OPTION' if opt == 'GRANT'
    end
    option_string
  end
end
