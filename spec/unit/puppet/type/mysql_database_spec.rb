# frozen_string_literal: true

require 'puppet'
require 'puppet/type/mysql_database'
describe Puppet::Type.type(:mysql_database) do
  let(:user) { Puppet::Type.type(:mysql_database).new(name: 'test', charset: 'utf8', collate: 'utf8_blah_ci') }

  it 'accepts a database name' do
    expect(user[:name]).to eq('test')
  end

  it 'accepts a charset' do
    user[:charset] = 'latin1'
    expect(user[:charset]).to eq('latin1')
  end

  it 'accepts a collate' do
    user[:collate] = 'latin1_swedish_ci'
    expect(user[:collate]).to eq('latin1_swedish_ci')
  end

  it 'requires a name' do
    expect {
      Puppet::Type.type(:mysql_database).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  describe 'utf8/utf8mb3 alias equivalence' do
    # MariaDB 11 (RHEL 10) reports the canonical `utf8mb3`, users request `utf8`.
    it 'treats charset utf8 and utf8mb3 as in sync' do
      resource = Puppet::Type.type(:mysql_database).new(name: 'test', charset: 'utf8')
      expect(resource.property(:charset).insync?('utf8mb3')).to be true
    end

    it 'treats charset utf8mb3 and utf8 as in sync' do
      resource = Puppet::Type.type(:mysql_database).new(name: 'test', charset: 'utf8mb3')
      expect(resource.property(:charset).insync?('utf8')).to be true
    end

    it 'treats collate utf8_general_ci and utf8mb3_general_ci as in sync' do
      resource = Puppet::Type.type(:mysql_database).new(name: 'test', collate: 'utf8_general_ci')
      expect(resource.property(:collate).insync?('utf8mb3_general_ci')).to be true
    end

    it 'still reports drift for a genuinely different charset' do
      resource = Puppet::Type.type(:mysql_database).new(name: 'test', charset: 'utf8')
      expect(resource.property(:charset).insync?('utf8mb4')).to be false
    end

    it 'still reports drift for a genuinely different collate' do
      resource = Puppet::Type.type(:mysql_database).new(name: 'test', collate: 'utf8_general_ci')
      expect(resource.property(:collate).insync?('latin1_swedish_ci')).to be false
    end

    it 'treats uppercase charset input as in sync with the lowercase server value' do
      resource = Puppet::Type.type(:mysql_database).new(name: 'test', charset: 'UTF8')
      expect(resource.property(:charset).insync?('utf8mb3')).to be true
    end

    it 'treats uppercase collate input as in sync with the lowercase server value' do
      resource = Puppet::Type.type(:mysql_database).new(name: 'test', collate: 'UTF8_GENERAL_CI')
      expect(resource.property(:collate).insync?('utf8mb3_general_ci')).to be true
    end
  end
end
