# frozen_string_literal: true

require 'spec_helper'

describe Facter::Util::Fact.to_s do
  before(:each) do
    Facter.clear
  end

  describe 'mysql_server_id' do
    context "igalic's laptop" do
      before :each do
        allow(Facter.fact(:macaddress)).to receive(:value).and_return('3c:97:0e:69:fb:e1')
      end

      it do
        expect(Facter.fact(:mysql_server_id).value).to be(241_857_808)
      end
    end

    context 'node with lo only' do
      before :each do
        allow(Facter.fact(:macaddress)).to receive(:value).and_return('00:00:00:00:00:00')
      end

      it do
        expect(Facter.fact(:mysql_server_id).value).to be(1)
      end
    end

    context 'test nil case' do
      before :each do
        allow(Facter.fact(:macaddress)).to receive(:value).and_return(nil)
      end

      it do
        expect(Facter.fact(:mysql_server_id).value).to be(nil)
      end
    end
  end
end
