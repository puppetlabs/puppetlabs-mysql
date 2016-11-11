require 'puppet'
require 'puppet/type/mysql_grant'
describe Puppet::Type.type(:mysql_grant) do
  before do
    @user = Puppet::Type.type(:mysql_grant).new(name: 'foo@localhost/*.*', privileges: %w(ALL PROXY), table: ['*.*', '@'], user: 'foo@localhost')
  end

  it 'accepts a grant name' do
    expect(@user[:name]).to eq('foo@localhost/*.*')
  end

  it 'accepts ALL privileges' do
    @user[:privileges] = 'ALL'
    expect(@user[:privileges]).to eq(['ALL'])
  end

  it 'accepts PROXY privilege' do
    @user[:privileges] = 'PROXY'
    expect(@user[:privileges]).to eq(['PROXY'])
  end

  it 'accepts a table' do
    @user[:table] = '*.*'
    expect(@user[:table]).to eq('*.*')
  end

  it 'accepts @ for table' do
    @user[:table] = '@'
    expect(@user[:table]).to eq('@')
  end

  it 'accepts a user' do
    @user[:user] = 'foo@localhost'
    expect(@user[:user]).to eq('foo@localhost')
  end

  it 'requires a name' do
    expect do
      Puppet::Type.type(:mysql_grant).new({})
    end.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'requires the name to match the user and table' do
    expect do
      Puppet::Type.type(:mysql_grant).new(name: 'foo', privileges: %w(ALL PROXY), table: ['*.*', '@'], user: 'foo@localhost')
    end.to raise_error /name must match user and table parameters/
  end

  describe 'it should munge privileges' do
    it 'to just ALL' do
      @user = Puppet::Type.type(:mysql_grant).new(
        name: 'foo@localhost/*.*', table: ['*.*', '@'], user: 'foo@localhost',
        privileges: %w(ALL PROXY)
)
      expect(@user[:privileges]).to eq(['ALL'])
    end

    it 'to upcase and ordered' do
      @user = Puppet::Type.type(:mysql_grant).new(
        name: 'foo@localhost/*.*', table: ['*.*', '@'], user: 'foo@localhost',
        privileges: %w(select Insert)
)
      expect(@user[:privileges]).to eq(%w(INSERT SELECT))
    end

    it 'ordered including column privileges' do
      @user = Puppet::Type.type(:mysql_grant).new(
        name: 'foo@localhost/*.*', table: ['*.*', '@'], user: 'foo@localhost',
        privileges: ['SELECT(Host,Address)', 'Insert']
)
      expect(@user[:privileges]).to eq(['INSERT', 'SELECT (Address, Host)'])
    end
  end
end
