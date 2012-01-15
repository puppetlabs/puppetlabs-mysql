Puppet::Type.type(:database_user).provide(:default) do

  desc "manage users for a mysql database."

  def create
    return false
  end
 
  def destroy
    return false
  end
 
  def exists?
    fail("this is just a default, it should not actually be used")
  end
 
  def password_hash
    return false
  end
 
  def password_hash=(string)
    return false
  end

  def self.instances
    Array.new
  end
end
