Puppet::Type.type(:database_user).provide(:mysql) do

  desc "manage users for a mysql database."

  defaultfor :kernel => 'Linux'

  optional_commands :mysql      => 'mysql'
  optional_commands :mysqladmin => 'mysqladmin'

  def self.instances
    users = mysql("--defaults-file=#{Facter.value(:root_home)}/.my.cnf", "mysql", '-BNe' "select concat(User, '@',Host) as User from mysql.user").split("\n")
    users.select{ |user| user =~ /.+@/ }.collect do |name|
      new(:name => name)
    end
  end

  def create
    mysql("--defaults-file=#{Facter.value(:root_home)}/.my.cnf", "mysql", "-e", "create user '%s' identified by PASSWORD '%s'" % [ @resource[:name].sub("@", "'@'"), @resource.value(:password_hash) ])
  end

  def destroy
    mysql("--defaults-file=#{Facter.value(:root_home)}/.my.cnf", "mysql", "-e", "drop user '%s'" % @resource.value(:name).sub("@", "'@'") )
  end

  def password_hash
    mysql("--defaults-file=#{Facter.value(:root_home)}/.my.cnf", "mysql", "-NBe", "select password from mysql.user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)).chomp
  end

  def password_hash=(string)
    mysql("--defaults-file=#{Facter.value(:root_home)}/.my.cnf", "mysql", "-e", "SET PASSWORD FOR '%s' = '%s'" % [ @resource[:name].sub("@", "'@'"), string ] )
  end

  def exists?
    not mysql("--defaults-file=#{Facter.value(:root_home)}/.my.cnf", "mysql", "-NBe", "select '1' from mysql.user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)).empty?
  end

  def flush
    @property_hash.clear
    mysqladmin "--defaults-file=#{Facter.value(:root_home)}/.my.cnf", "flush-privileges"
  end

end
