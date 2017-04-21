require 'spec_helper'

describe Facter::Util::Fact do
  before { Facter.clear }

  context 'mysqld_version' do
    before do
    end
    it {
      Facter::Util::Resolution.stubs(:exec).with('mysqld -V 2>/dev/null').returns('mysqld  Ver 5.5.49-37.9 for Linux on x86_64 (Percona Server (GPL), Release 37.9, Revision efa0073)')
      expect(Facter.fact(:mysqld_version).value).to eq('mysqld  Ver 5.5.49-37.9 for Linux on x86_64 (Percona Server (GPL), Release 37.9, Revision efa0073)')
    }
  end
end
