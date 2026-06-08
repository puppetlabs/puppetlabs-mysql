# frozen_string_literal: true

require 'spec_helper'

describe Facter::Util::Fact.to_s do
  before(:each) do
    Facter.clear
  end

  describe 'mysql_server_id' do
    context "igalic's laptop" do
      before :each do
        allow(Facter).to receive(:value).with(:macaddress).and_return('3c:97:0e:69:fb:e1')
      end

      it do
        Facter.fact(:mysql_server_id).value.to_s.should == '241857808'
      end
    end

    context 'node with lo only' do
      before :each do
        allow(Facter).to receive(:value).with(:macaddress).and_return('00:00:00:00:00:00')
      end

      it do
        Facter.fact(:mysql_server_id).value.to_s.should == '1'
      end
    end

    context 'test nil case' do
      before :each do
        allow(Facter).to receive(:value).with(:macaddress).and_return(nil)
      end

      it do
        Facter.fact(:mysql_server_id).value.to_s.should == ''
      end
    end
  end
end
