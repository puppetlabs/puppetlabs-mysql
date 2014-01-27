require 'spec_helper'
require 'facter/mysql_version'

describe 'Fact mysql_version' do
  before(:each) do
    Facter.clear
  end
  context "centos 6" do
    it "should return the version" do
      Facter::Util::Resolution.expects(:exec).once.with('mysql --version').returns('mysql  Ver 14.14 Distrib 5.1.71, for redhat-linux-gnu (x86_64) using readline 5.1')
      Facter.fact(:mysql_version).value.should == '5.1.71'
    end
  end
  context "centos 5" do
    it "should return the version" do
      Facter::Util::Resolution.expects(:exec).once.with('mysql --version').returns('mysql  Ver 14.12 Distrib 5.0.95, for redhat-linux-gnu (x86_64) using readline 5.1')
      Facter.fact(:mysql_version).value.should == '5.0.95'
    end
  end
  context "no mysql present" do
    it "should be nil without mysql installed" do
      Facter::Util::Resolution.expects(:exec).once.with('mysql --version').returns(nil)
      Facter.fact(:mysql_version).value.should be_nil
    end
  end
end
