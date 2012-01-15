require 'spec_helper'
require 'mysql'

provider = Puppet::Type.type(:database_user).provider(:mysql)

describe provider do
  let(:instance) { provider.new( :name => 'testuser@testhost', :password_hash => '8383mypasshash8383', :ensure => :present) }
  let(:resource) { {:name => 'testuser@testhost', :password_hash => '8383mypasshash8383'} }
  let(:mysql)    { mock('Mysql') }

  describe '#create' do
    before :each do
      mock_mysql = mysql
      provider.expects(:connect).returns(mock_mysql)
      mock_mysql.expects(:select_db).with("mysql").returns(mock_mysql)
      mock_mysql.expects(:reload)
      mock_mysql.expects(:query).with("create user 'testuser'@'testhost' identified by PASSWORD '8383mypasshash8383'")
    end

    it 'should create user' do
      instance.instance_variable_set '@resource', resource
      instance.create
    end

    it 'should set property hash' do
      new_property_hash = instance.instance_variable_get '@property_hash'
      new_property_hash[:ensure => :absent]
      instance.instance_variable_set '@property_hash', new_property_hash

      instance.instance_variable_set '@resource', resource
      instance.create
      instance.instance_variable_get('@property_hash').should == {:ensure=>:present, :name=>"testuser@testhost", :password_hash=>"8383mypasshash8383"}
    end
  end

  describe '#destroy' do
    before :each do
      mock_mysql = mysql
      provider.expects(:connect).returns(mock_mysql)
      mock_mysql.expects(:select_db).with("mysql").returns(mock_mysql)
      mock_mysql.expects(:reload)
      mock_mysql.expects(:query).with("drop user 'testuser'@'testhost'")
    end

    it 'should drop privileges for the user globally' do
      instance.instance_variable_set '@resource', resource
      instance.destroy
    end

    it 'should set property hash' do
      instance.instance_variable_set '@resource', resource
      instance.destroy
      instance.instance_variable_get('@property_hash').should == { :ensure => :absent, :name => 'testuser@testhost', :password_hash => '8383mypasshash8383' }
    end
  end

  describe '#password_hash' do
    it 'should return the hash' do
      instance.password_hash.should == '8383mypasshash8383'
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
