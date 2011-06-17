Puppet::Type.type(:database).provide(:mysql) do

  desc "Create mysql database."

  defaultfor :kernel => 'Linux'

  commands :mysqladmin => 'mysqladmin'
  commands :mysql      => 'mysql'
  commands :mysqlshow  => 'mysqlshow'
	
  def create
    mysql('-NBe', "CREATE DATABASE #{@resource[:name]} CHARACTER SET #{resource[:charset]}")
  end

  def destroy
    mysqladmin('-f', 'drop', @resource[:name])
  end

  def exists?
    begin
      mysql('-NBe', "show databases").match(/^#{@resource[:name]}$/)
    rescue => e
      debug(e.message)
      return nil
    end
  end
 
  def charset
    mysql('-NBe', "show create database #{resource[:name]}").match(/.*?(\S+)\s\*\//)[1]
  end

  def charset=(value)
    mysql('-NBe', "alter database #{resource[:name]} CHARACTER SET #{value}")
  end
  # retrieve the current set of mysql databases
end

