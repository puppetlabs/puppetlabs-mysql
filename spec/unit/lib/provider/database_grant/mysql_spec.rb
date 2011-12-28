require 'spec_helper'
require 'mysql'

provider = Puppet::Type.type(:database_grant).provider(:mysql)

describe provider do
  let(:dbinstance)     { provider.new( :name => 'testuser@testhost/testdb', :privileges => [:all], :ensure => :present, :user => 'testuser', :host => 'testhost', :database => 'testdb') }
  let(:globalinstance) { provider.new( :name => 'testuser@testhost', :privileges => [:all], :ensure => :present, :user => 'testuser', :host => 'testhost') }
  let(:globalresource) { {:name => 'testuser@testhost', :privileges=> [:all]} }
  let(:dbresource)     { {:name => 'testuser@testhost/testdb', :privileges=> [:all]} }
  let(:mysql)          { mock('Mysql') }

  describe '#create' do
    context 'for global users' do
      before :each do
        mock_mysql = mysql
        provider.expects(:connect).returns(mock_mysql)
        mock_mysql.expects(:select_db).with("mysql").returns(mock_mysql)
        mock_mysql.expects(:reload)
        mock_mysql.expects(:query).with("INSERT INTO user (host, user) VALUES ('testhost', 'testuser')")
        globalinstance.expects(:privileges=).with([:all])
      end

      it 'should insert users' do
        globalinstance.instance_variable_set '@resource', globalresource
        globalinstance.create
      end

      it 'should set property hash' do
        new_property_hash = globalinstance.instance_variable_get '@property_hash'
        new_property_hash[:ensure => :absent]
        globalinstance.instance_variable_set '@property_hash', new_property_hash

        globalinstance.instance_variable_set '@resource', globalresource
        globalinstance.create
        globalinstance.instance_variable_get('@property_hash').should == { :name => 'testuser@testhost', :privileges => [:all], :ensure => :present, :user => 'testuser', :host => 'testhost' }
      end
    end

    context 'for database users' do
      before :each do
        mock_mysql = mysql
        provider.expects(:connect).returns(mock_mysql)
        mock_mysql.expects(:select_db).with("mysql").returns(mock_mysql)
        mock_mysql.expects(:reload)
        mock_mysql.expects(:query).with("INSERT INTO db (host, user, db) VALUES ('testhost', 'testuser', 'testdb')")
        dbinstance.expects(:privileges=).with([:all])
      end


      it 'should create insert users into a database' do
        dbinstance.instance_variable_set '@resource', dbresource
        dbinstance.create
      end

      it 'should set property hash' do
        new_property_hash = dbinstance.instance_variable_get '@property_hash'
        new_property_hash[:ensure => :absent]
        dbinstance.instance_variable_set '@property_hash', new_property_hash

        dbinstance.instance_variable_set '@resource', dbresource
        dbinstance.create
        dbinstance.instance_variable_get('@property_hash').should == { :name => 'testuser@testhost/testdb', :privileges => [:all], :ensure => :present, :user => 'testuser', :host => 'testhost', :database => 'testdb' }
      end
    end
  end

  describe '#destroy' do
    context 'for global users' do
      before :each do
        mock_mysql = mysql
        provider.expects(:connect).returns(mock_mysql)
        mock_mysql.expects(:select_db).with("mysql").returns(mock_mysql)
        mock_mysql.expects(:query).with("REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'testuser'@'testhost'")
      end

      it 'should drop privileges for the user globally' do
        globalinstance.instance_variable_set '@resource', globalresource
        globalinstance.destroy
      end

      it 'should set property hash' do
        globalinstance.instance_variable_set '@resource', globalresource
        globalinstance.destroy
        globalinstance.instance_variable_get('@property_hash').should == { :name => 'testuser@testhost', :privileges => [:all], :ensure => :absent, :user => 'testuser', :host => 'testhost' }
      end
    end

    context 'for database users' do
      before :each do
        mock_mysql = mysql
        provider.expects(:connect).returns(mock_mysql)
        mock_mysql.expects(:select_db).with("mysql").returns(mock_mysql)
        mock_mysql.expects(:query).with("REVOKE ALL ON testdb.* FROM 'testuser'@'testhost'")
      end

      it 'should drop privileges for the user per database' do
        dbinstance.instance_variable_set '@resource', dbresource
        dbinstance.destroy
      end

      it 'should set property hash' do
        dbinstance.instance_variable_set '@resource', dbresource
        dbinstance.destroy
        dbinstance.instance_variable_get('@property_hash').should == { :name => 'testuser@testhost/testdb', :privileges => [:all], :ensure => :absent, :user => 'testuser', :host => 'testhost', :database => 'testdb' }
      end
    end
  end

  describe '#privileges' do
    it 'should return privileges as symbols in an array' do
      mock_mysql = mysql
      provider.expects(:connect).returns(mock_mysql)
      mock_mysql.expects(:select_db).with("mysql").returns(mock_mysql)
      mock_mysql.expects(:query).with("update db set select_priv = 'N', insert_priv = 'N', update_priv = 'Y', delete_priv = 'N', create_priv = 'Y', drop_priv = 'Y', grant_priv = 'N', references_priv = 'N', index_priv = 'N', alter_priv = 'N', create_tmp_table_priv = 'N', lock_tables_priv = 'N', create_view_priv = 'N', show_view_priv = 'N', create_routine_priv = 'N', alter_routine_priv = 'N', execute_priv = 'N' where user=\"testuser\" and host=\"testhost\" and db=\"testdb\"")
      mock_mysql.expects(:reload)
      dbinstance.instance_variable_set '@resource', dbresource
      dbinstance.privileges.should == [ :all ]
      dbinstance.privileges = [ :update, :create, :drop ]
      dbinstance.privileges.should =~ [ :drop, :update, :create ]
    end
  end
    
  describe '#connect' do
    let(:iniconfig) { Puppet::Util::IniConfig::File }

    after :each do
      File.unlink(File.join(Dir.tmpdir, 'my.cnf'))
    end

    it 'should use credentials in /root/.my.cnf if present' do
      File.expects(:exists?).with('/root/.my.cnf').returns(true)

      ## Create a fake my.cnf
      tmpfile = File.join  Dir.tmpdir, 'my.cnf' 
      File.open(tmpfile, 'w') do |f|
        f.write "[client]
user=root
host=localhost
password=password"
      end

      ## Create a iniconfig object we can control
      fake_ini = Puppet::Util::IniConfig::File.new
      fake_ini.read tmpfile

      Puppet::Util::IniConfig::File.expects(:new).returns( fake_ini )
      fake_ini.expects(:read).with('/root/.my.cnf').returns( nil )

      mock_mysql = mysql
      Mysql.expects(:new).with 'localhost', 'root', 'password'

      Puppet::Type.type(:database).provider(:mysql).connect
    end
  end
end
