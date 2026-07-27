# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:mysql_grant).provider(:mysql) do
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

      allow(described_class).to receive(:instances).with(['alice@localhost', 'bob@localhost']).and_return([alice_provider, bob_provider])
      allow(grant_one).to receive(:provider=)
      allow(grant_two).to receive(:provider=)
      allow(grant_three).to receive(:provider=)

      described_class.prefetch(resources)

      expect(described_class).to have_received(:instances).with(['alice@localhost', 'bob@localhost'])
      expect(grant_one).to have_received(:provider=).with(alice_provider)
      expect(grant_two).not_to have_received(:provider=)
      expect(grant_three).to have_received(:provider=).with(bob_provider)
    end
  end
end
