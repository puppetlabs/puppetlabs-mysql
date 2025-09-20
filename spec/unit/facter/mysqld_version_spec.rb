# frozen_string_literal: true

require 'spec_helper'

describe Facter::Util::Fact.to_s do
  before(:each) do
    Facter.clear
  end

  describe 'mysqld_version' do
    context 'with mysqld' do
      before :each do
        allow(Facter::Core::Execution).to receive(:which).with('mysqld').and_return('/usr/sbin/mysqld')
        allow(Facter::Core::Execution).to receive(:which).with('/usr/libexec/mysqld').and_return(false)
        allow(Facter::Core::Execution).to receive(:which).with('mariadbd').and_return(false)
        allow(Facter::Core::Execution).to receive(:execute).with('mysqld --no-defaults -V 2>/dev/null')
                                                           .and_return('mysqld  Ver 5.5.49-37.9 for Linux on x86_64 (Percona Server (GPL), Release 37.9, Revision efa0073)')
      end

      it {
        expect(Facter.fact(:mysqld_version).value).to eq('mysqld  Ver 5.5.49-37.9 for Linux on x86_64 (Percona Server (GPL), Release 37.9, Revision efa0073)')
      }
    end

    context 'with mysqld in /usr/libexec/mysqld' do
      before :each do
        allow(Facter::Core::Execution).to receive(:which).with('mysqld').and_return(false)
        allow(Facter::Core::Execution).to receive(:which).with('/usr/libexec/mysqld').and_return('/usr/libexec/mysqld')
        allow(Facter::Core::Execution).to receive(:which).with('mariadbd').and_return(false)
        allow(Facter::Core::Execution).to receive(:execute).with('/usr/libexec/mysqld --no-defaults -V 2>/dev/null')
                                                           .and_return('mysqld  Ver 5.5.49-37.9 for Linux on x86_64 (Percona Server (GPL), Release 37.9, Revision efa0073)')
      end

      it {
        expect(Facter.fact(:mysqld_version).value).to eq('mysqld  Ver 5.5.49-37.9 for Linux on x86_64 (Percona Server (GPL), Release 37.9, Revision efa0073)')
      }
    end

    context 'with mariadb' do
      before :each do
        allow(Facter::Core::Execution).to receive(:which).with('mysqld').and_return(false)
        allow(Facter::Core::Execution).to receive(:which).with('/usr/libexec/mysqld').and_return(false)
        allow(Facter::Core::Execution).to receive(:which).with('mariadbd').and_return('/usr/sbin/mariadbd')
        allow(Facter::Core::Execution).to receive(:execute).with('mariadbd --no-defaults -V 2>/dev/null')
                                                           .and_return('mariadbd  Ver 11.4.2-MariaDB-ubu2404 for debian-linux-gnu on x86_64 (mariadb.org binary distribution)')
      end

      it {
        expect(Facter.fact(:mysqld_version).value).to eq('mariadbd  Ver 11.4.2-MariaDB-ubu2404 for debian-linux-gnu on x86_64 (mariadb.org binary distribution)')
      }
    end
  end
end
