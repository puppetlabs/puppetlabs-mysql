Puppet::Type.type(:database).provide(:mysql) do

  desc "Manages MySQL database."

  defaultfor :kernel => 'Linux'

  optional_commands :mysql      => 'mysql'
  optional_commands :mysqladmin => 'mysqladmin'

  def defaults_file
    case Facter.value(:operatingsystem)
    when "Debian", "Ubuntu"
      return "--defaults-file=/etc/mysql/debian.cnf"
    else
      return ""
    end
  end

  def self.instances
    mysql(defaults_file, '-NBe', "show databases").split("\n").collect do |name|
      new(:name => name)
    end
  end

  def create
    mysql(defaults_file, '-NBe', "create database `#{@resource[:name]}` character set #{resource[:charset]}")
  end

  def destroy
    mysqladmin(defaults_file, '-f', 'drop', @resource[:name])
  end

  def charset
    mysql(defaults_file, '-NBe', "show create database `#{resource[:name]}`").match(/.*?(\S+)\s\*\//)[1]
  end

  def charset=(value)
    mysql(defaults_file, '-NBe', "alter database `#{resource[:name]}` CHARACTER SET #{value}")
  end

  def exists?
    begin
      mysql(defaults_file, '-NBe', "show databases").match(/^#{@resource[:name]}$/)
    rescue => e
      debug(e.message)
      return nil
    end
  end

end

