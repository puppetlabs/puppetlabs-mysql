require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
  }

  describe "mysql_server_id" do
    context "developer laptop" do
      before :each do
        Facter.fact(:ipaddress).stubs(:value).returns('192.168.1.100')
      end
      it do
        Facter.fact(:mysql_server_id).value.to_s.should == '1739024'
      end
    end

    context "node with lo only" do
      before :each do
        Facter.fact(:ipaddress_lo).stubs(:value).returns('172.0.0.1)
      end
      it do
        Facter.fact(:mysql_server_id).value.to_s.should == '1515521'
      end
    end
  end
end
