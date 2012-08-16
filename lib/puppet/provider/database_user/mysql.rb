Puppet::Type.type(:database_user).provide(:mysql) do

  desc "manage users for a mysql database."

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
    users = mysql(defaults_file, '-BNe' "select concat(User, '@',Host) as User from mysql.user").split("\n")
    users.select{ |user| user =~ /.+@/ }.collect do |name|
      new(:name => name)
    end
  end

  def create
    mysql(defaults_file, "-e", "create user '%s' identified by PASSWORD '%s'" % [ @resource[:name].sub("@", "'@'"), @resource.value(:password_hash) ])
  end

  def destroy
    mysql(defaults_file, "-e", "drop user '%s'" % @resource.value(:name).sub("@", "'@'") )
  end

  def password_hash
    mysql(defaults_file, "-NBe", "select password from user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)).chomp
  end

  def password_hash=(string)
    mysql(defaults_file, "-e", "SET PASSWORD FOR '%s' = '%s'" % [ @resource[:name].sub("@", "'@'"), string ] )
  end

  def exists?
    not mysql(defaults_file, "-NBe", "select '1' from user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)).empty?
  end

  def flush
    @property_hash.clear
    mysqladmin(defaults_file, "flush-privileges")
  end

end
