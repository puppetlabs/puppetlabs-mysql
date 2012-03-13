# A grant is either global or per-db. This can be distinguished by the syntax
# of the name:
#   user@host => global
#   user@host/db => per-db

Puppet::Type.type(:database_grant).provide(:default) do

  desc "Uses mysql as database."

  def self.instances
    []
  end

  def destroy
    return false
  end

  def create
    return false
  end

  def exists?
    fail('Default provider for database_grant should never be used')
  end

end

