Puppet::Type.type(:database).provide(:default) do

  desc "This is a default provider that does nothing. This allows us to install mysql on the same puppet run where we want to use it."

  def self.instances
    []
  end

  def create
    return false
  end

  def destroy
    return false
  end

  def exists?
    fail('This is just the default provider for database, all it does is fail')
  end

  def charset
    return false
  end

  def charset=(value)
    return false
  end
end
