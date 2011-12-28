Puppet::Type.type(:database).provide(:mysql) do
  begin
    require 'mysql'
  rescue LoadError
    confine :true => false
  end

  require 'puppet/util/inifile'

  desc "Manage a MySQL database."

  defaultfor :kernel => 'Linux'

  def create
    Puppet::Type.type(:database).provider(:mysql).connect.query("CREATE DATABASE #{@resource[:name]} CHARACTER SET #{@resource[:charset]}")
    @property_hash[:ensure]  = :present
    @property_hash[:charset] = @resource[:charset]
  end

  def destroy
    Puppet::Type.type(:database).provider(:mysql).connect.query("DROP DATABASE #{@resource[:name]}")
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] == :present ? true : false
  end
 
  def charset
    @property_hash[:charset]
  end

  def charset=(value)
    @property_hash[:charset] = value
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def self.instances
    dbh = self.connect
    dbh.list_dbs.map do |db|

      charset = dbh.select_db(db).query('show variables like "character_set_database"').fetch_row.last

      @property_hash = {:name => db, :ensure => :present, :charset => charset}
      new @property_hash
    end
  end

  def self.connect
    if File.exists? '/root/.my.cnf'
      config = Puppet::Util::IniConfig::File.new
      config.read '/root/.my.cnf'
      unless config['client'].nil?
        config_host   = config['client']['host']
        config_user   = config['client']['user']
        config_passwd = config['client']['password']
        Mysql.new host=config_host, user=config_user, passwd=config_passwd
      else
        Mysql.new
      end
    else
      Mysql.new
    end
  end
end
