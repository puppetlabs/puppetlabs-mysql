# frozen_string_literal: true

require 'spec_helper'

describe Facter::Util::Fact.to_s do
  before(:each) do
    Facter.clear
  end

  describe 'mysql_version' do
    context 'with mysql' do
      before :each do
        allow(Facter::Core::Execution).to receive(:which).with('mysql').and_return('fake_mysql_path')
        allow(Facter::Core::Execution).to receive(:which).with('mariadb').and_return(false)
        allow(Facter::Core::Execution).to receive(:execute).with('mysql --version').and_return('mysql  Ver 14.12 Distrib 5.0.95, for redhat-linux-gnu (x86_64) using readline 5.1')
      end

      it {
        expect(Facter.fact(:mysql_version).value).to eq('5.0.95')
      }
    end

    context 'with mariadb' do
      before :each do
        allow(Facter::Core::Execution).to receive(:which).with('mysql').and_return(false)
        allow(Facter::Core::Execution).to receive(:which).with('mariadb').and_return('/usr/bin/mariadb')
        allow(Facter::Core::Execution).to receive(:execute).with('mariadb --version').and_return('mariadb from 11.4.2-MariaDB, client 15.2 for debian-linux-gnu (x86_64) using  EditLine wrapper')
      end

      it {
        expect(Facter.fact(:mysql_version).value).to eq('11.4.2')
      }
    end
  end
end
