# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:mysql_grant).provider(:mysql) do
  describe 'self.instances' do
    it 'loads grants only for the managed users list' do
      allow(described_class).to receive(:newer_than).and_return(false)
      expect(described_class).not_to receive(:users)
      expect(described_class).to receive(:mysql_caller).with("SHOW GRANTS FOR 'alice'@'localhost';", 'regular').and_return("GRANT SELECT ON `db_one`.* TO 'alice'@'localhost'\n")
      expect(described_class).not_to receive(:mysql_caller).with("SHOW GRANTS FOR 'bob'@'localhost';", 'regular')

      instances = described_class.instances(['alice@localhost'])

      expect(instances.map(&:name)).to eq(['alice@localhost/db_one.*'])
    end

    it 'falls back to full user scan when managed user list is empty' do
      allow(described_class).to receive(:newer_than).and_return(false)
      expect(described_class).to receive(:users).and_return(['alice@localhost'])
      allow(described_class).to receive(:mysql_caller).with("SHOW GRANTS FOR 'alice'@'localhost';", 'regular').and_return("GRANT SELECT ON `db_one`.* TO 'alice'@'localhost'\n")

      instances = described_class.instances([])

      expect(instances.map(&:name)).to eq(['alice@localhost/db_one.*'])
    end
  end

  describe 'self.prefetch' do
    it 'only loads grants for managed users from resources' do
      grant_one = instance_double(Puppet::Type.type(:mysql_grant))
      grant_two = instance_double(Puppet::Type.type(:mysql_grant))
      grant_three = instance_double(Puppet::Type.type(:mysql_grant))

      resources = {
        'alice@localhost/db_one.*' => grant_one,
        'alice@localhost/db_two.*' => grant_two,
        'bob@localhost/db_one.*' => grant_three
      }

      alice_provider = instance_double(described_class, name: 'alice@localhost/db_one.*')
      bob_provider = instance_double(described_class, name: 'bob@localhost/db_one.*')

      expect(described_class).to receive(:instances).with(['alice@localhost', 'bob@localhost']).and_return([alice_provider, bob_provider])
      expect(grant_one).to receive(:provider=).with(alice_provider)
      expect(grant_two).not_to receive(:provider=)
      expect(grant_three).to receive(:provider=).with(bob_provider)

      described_class.prefetch(resources)
    end
  end
end
