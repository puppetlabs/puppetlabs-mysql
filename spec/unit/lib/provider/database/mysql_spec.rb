require 'spec_helper'
require 'mysql'

provider = Puppet::Type.type(:database).provider(:mysql)

describe provider do
  let(:instance) { provider.new( :name => 'testdb', :charset => 'utf8', :ensure => :present) }
  let(:resource) { {:name => 'testdb', :charset => 'utf8', :ensure => :present} }
  let(:mysql)    { mock('Mysql') }

  describe '#create' do
    before :each do
      mock_mysql = mysql
      Mysql.expects(:new).returns(mock_mysql)
      mock_mysql.expects(:query).with('CREATE DATABASE testdb CHARACTER SET utf8')
    end

    it 'should create a database' do
      instance.instance_variable_set '@resource', resource
      instance.create
    end

    it 'should set property hash' do
      new_property_hash = instance.instance_variable_get '@property_hash'
      new_property_hash[:ensure => :absent]
      instance.instance_variable_set '@property_hash', new_property_hash

      instance.instance_variable_set '@resource', resource
      instance.create
      instance.instance_variable_get('@property_hash').should == { :name => 'testdb', :charset => 'utf8', :ensure => :present }
    end
  end

  describe '#destroy' do
    before :each do
      mock_mysql = mysql
      Mysql.expects(:new).returns(mock_mysql)
      mock_mysql.expects(:query).with('DROP DATABASE testdb')
    end

    it 'should drop a database' do
      instance.instance_variable_set '@resource', resource
      instance.destroy
    end

    it 'should set property hash' do
      instance.instance_variable_set '@resource', resource
      instance.destroy
      instance.instance_variable_get('@property_hash').should == { :name => 'testdb', :charset => 'utf8', :ensure => :absent }
    end
  end

  describe '#charset' do
    it 'should return character set' do
      instance.charset.should == 'utf8'
    end
  end

  describe '#charset=' do
    it 'should set character set property' do
      instance.charset = 'latin1'
      instance.instance_variable_get('@property_hash')[:charset].should == 'latin1'
    end
  end

  describe '#connect' do
    let(:iniconfig) { Puppet::Util::IniConfig::File }

    #after :each do
    #  File.unlink(File.join(Dir.tmpdir, 'my.cnf'))
    #end

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
      fake_ini = iniconfig.new
      fake_ini.read tmpfile

      iniconfig.expects(:new).returns( fake_ini )
      fake_ini.expects(:read).with('/root/.my.cnf').returns( nil )

      mock_mysql = mysql
      Mysql.expects(:new).with 'localhost', 'root', 'password'

      Puppet::Type.type(:database).provider(:mysql).connect

      File.unlink tmpfile
    end
  end
end
