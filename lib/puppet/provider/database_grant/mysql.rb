# A grant is either global or per-db. This can be distinguished by the syntax
# of the name:
#   user@host => global
#   user@host/db => per-db

MYSQL_USER_PRIVS = [ :select, :insert, :update, :delete,
  :create, :drop, :reload, :shutdown, :process,
  :file, :grant, :references, :index, :alter,
  :show_db, :super, :create_tmp_table, :lock_tables,
  :execute, :repl_slave, :repl_client, :create_view,
  :show_view, :create_routine, :alter_routine,
  :create_user, :event, :trigger
]

MYSQL_DB_PRIVS = [ :select, :insert, :update, :delete,
  :create, :drop, :grant, :references, :index,
  :alter, :create_tmp_table, :lock_tables, :create_view,
  :show_view, :create_routine, :alter_routine, :execute
]

Puppet::Type.type(:database_grant).provide(:mysql) do

  begin
    require 'mysql'
  rescue LoadError
    confine :true => false
  end

  require 'puppet/util/inifile'

  desc "Uses mysql as database."

  defaultfor :kernel => 'Linux'

  # this parses the
  def split_name(string)
    matches = /^([^@]*)@([^\/]*)(\/(.*))?$/.match(string).captures.compact
    case matches.length 
      when 2
        {
          :type => :user,
          :user => matches[0],
          :host => matches[1]
        }
      when 4
        {
          :type => :db,
          :user => matches[0],
          :host => matches[1],
          :db => matches[3]
        }
    end
  end

  def create
    if @resource[:privileges].nil? or @resource[:privileges].empty?
      Puppet.warning 'No privileges given. Defaulting to all'
      @resource[:privileges] = [:all]
    end

    dbh = Puppet::Type.type(:database_grant).provider(:mysql).connect
    db = dbh.select_db('mysql')
    name = split_name(@resource[:name])
    case name[:type]
    when :user
      db.query("INSERT INTO user (host, user) VALUES ('%s', '%s')" % [
        name[:host], name[:user],
      ] )
    when :db
      db.query("INSERT INTO db (host, user, db) VALUES ('%s', '%s', '%s')" % [
        name[:host], name[:user], name[:db],
      ] )
    end
    dbh.reload
    @property_hash[:ensure] = :present

    self.privileges = @resource[:privileges]
  end

  def destroy
    dbh = Puppet::Type.type(:database_grant).provider(:mysql).connect
    name = split_name(@resource[:name])
    case name[:type]
    when :user
      dbh.select_db('mysql').query("REVOKE ALL PRIVILEGES, GRANT OPTION FROM '%s'@'%s'" % [ @property_hash[:user], @property_hash[:host] ])
    when :db
      dbh.select_db('mysql').query("REVOKE ALL ON %s.* FROM '%s'@'%s'" % [ @property_hash[:database], @property_hash[:user], @property_hash[:host] ])
    end

    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] == :present ? true : false
  end

  def privileges
    name = split_name(@property_hash[:name])
    privs_hash = name[:type] == :user ? MYSQL_USER_PRIVS : MYSQL_DB_PRIVS
    if (@property_hash[:privileges].sort == privs_hash.sort) or (@property_hash[:privileges] == [ :all ])
      [:all]
    else
      @property_hash[:privileges]
    end
  end

  def privileges=(privs)
    name = split_name(@resource[:name])
    stmt = ''
    where = ''
    all_privs = []
    case name[:type]
    when :user
      stmt = 'update user set '
      where = ' where user="%s" and host="%s"' % [ name[:user], name[:host] ]
      all_privs = MYSQL_USER_PRIVS
    when :db
      stmt = 'update db set '
      where = ' where user="%s" and host="%s" and db="%s"' % [ name[:user], name[:host], name[:db] ]
      all_privs = MYSQL_DB_PRIVS
    end

    if privs[0] == :all 
      set = all_privs.collect { |p| "#{p}_priv = 'Y'" }.join(', ')
    else
      set = all_privs.collect do |p| 
        "%s = '%s'" % ["#{p}_priv", privs.include?(p) ? 'Y' : 'N'] 
      end.join(', ')
    end

    stmt = stmt << set << where

    dbh = Puppet::Type.type(:database_grant).provider(:mysql).connect
    dbh.select_db('mysql').query stmt
    dbh.reload
    @property_hash[:privileges] = privs
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

    ## Get DB users
    dbh.query('select * from mysql.db').each_hash do |result|
      user = result['User']
      host = result['Host']
      db   = result['Db']

      db_privs = Array.new
      result.each do |property,value|

        property = property.downcase[0...-5].to_sym if property =~ /_priv$/
        if MYSQL_DB_PRIVS.include?(property) and value == "Y"
          db_privs << property
        end
      end
      @property_hash = { :name => "#{user}@#{host}/#{db}", :privileges => db_privs, :ensure => :present, :host => host, :database => db, :user => user }
      instances << new(@property_hash)
    end

    ## Get primary users
    dbh.query('select * from mysql.user').each_hash do |result|
      host = result['Host']
      user = result['User']

      db_privs = Array.new
      result.each do |property,value| 
        property = property.downcase[0...-5].to_sym if property =~ /_priv$/
        if MYSQL_USER_PRIVS.include?(property) and value == 'Y'
          db_privs << property
        end
      end
      @property_hash = { :name => "#{user}@#{host}", :privileges => db_privs, :ensure => :present, :host => host, :user => user }
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
