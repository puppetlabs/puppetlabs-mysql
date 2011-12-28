Puppet::Type.type(:database_user).provide(:mysql) do
  begin
    require 'mysql'
  rescue LoadError
    confine :true => false
  end

  require 'puppet/util/inifile'

  desc "manage users for a mysql database."

  defaultfor :kernel => 'Linux'

  def create
    dbh = Puppet::Type.type(:database_user).provider(:mysql).connect
    dbh.select_db('mysql').query("create user '%s' identified by PASSWORD '%s'" % [ @resource[:name].sub("@", "'@'"), @resource[:password_hash] ])
    dbh.reload
    @property_hash[:ensure] = :present
    @property_hash[:password_hash] = @resource[:password_hash]
  end
 
  def destroy
    dbh = Puppet::Type.type(:database_user).provider(:mysql).connect
    dbh.select_db('mysql').query("drop user '%s'" % @resource[:name].sub("@", "'@'"))
    dbh.reload
    @property_hash[:ensure] = :absent
  end
 
  def exists?
    @property_hash[:ensure] == :present ? true : false    
  end
 
  def password_hash
    @property_hash[:password_hash]
  end
 
  def password_hash=(string)
    dbh = Puppet::Type.type(:database_user).provider(:mysql).connect
    dbh.select_db('mysql').query("SET PASSWORD FOR '%s' = '%s'" % [ @resource[:name].sub("@", "'@'"), string ])
    dbh.reload
    @property_hash[:password_hash] = string
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
    instances = Array.new

    dbh.select_db('mysql').query('SELECT * FROM user').each_hash do |result|
      host = result['Host']
      user = result['User']
      password_hash = result['Password']

      @property_hash = { :name => "#{user}@#{host}", :user => user, :password_hash => password_hash, :host => host, :ensure => :present }
      instances << new(@property_hash)
    end
    instances
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
      end
    else
      Mysql.new
    end
  end
end
