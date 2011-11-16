Puppet::Type.type(:database_user).provide(:mysql) do

  desc "manage users for a mysql database."

  defaultfor :kernel => 'Linux'

  optional_commands :mysql => 'mysql'
  optional_commands :mysqladmin => 'mysqladmin'

  def create
    mysql "mysql", "-e", "create user '%s' identified by PASSWORD '%s'" % [ @resource[:name].sub("@", "'@'"), @resource.value(:password_hash) ]
    mysql_flush
  end
 
  def destroy
    mysql "mysql", "-e", "drop user '%s'" % @resource.value(:name).sub("@", "'@'")
    mysql_flush
  end
 
  def exists?
    not mysql("mysql", "-NBe", "select '1' from user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)).empty?
  end
 
  def password_hash
    mysql("mysql", "-NBe", "select password from user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)).chomp
  end
 
  def password_hash=(string)
    mysql "mysql", "-e", "SET PASSWORD FOR '%s' = '%s'" % [ @resource[:name].sub("@", "'@'"), string ]
    mysql_flush
  end

  private

  def mysql_flush
    mysqladmin "flush-privileges"
  end
end
