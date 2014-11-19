require 'puppet'
require 'puppet/type/mysql_user'
describe Puppet::Type.type(:mysql_user) do

  it 'should require a name' do
    expect {
      Puppet::Type.type(:mysql_user).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  context 'using 12345678901234567@localhost' do
    before :each do
      @user = Puppet::Type.type(:mysql_user).new(:name => '12345678901234567@localhost', :password_hash => 'pass')
    end

    it 'should accept a user name' do
      expect(@user[:name]).to eq('12345678901234567@localhost')
    end

    it 'should accept a password' do
      @user[:password_hash] = 'foo'
      expect(@user[:password_hash]).to eq('foo')
    end
  end

  context 'using foo@LocalHost' do
    before :each do
      @user = Puppet::Type.type(:mysql_user).new(:name => 'foo@LocalHost', :password_hash => 'pass')
    end

    it 'should lowercase the user name' do
      expect(@user[:name]).to eq('foo@localhost')
    end
  end

  context 'using allo_wed$char@localhost' do
    before :each do
      @user = Puppet::Type.type(:mysql_user).new(:name => 'allo_wed$char@localhost', :password_hash => 'pass')
    end

    it 'should accept a user name' do
      expect(@user[:name]).to eq('allo_wed$char@localhost')
    end
  end

  context 'using `speci!al#`@localhost' do
    before :each do
      @user = Puppet::Type.type(:mysql_user).new(:name => '`speci!al#`@localhost', :password_hash => 'pass')
    end

    it 'should accept a quoted user name with special chatracters' do
      expect(@user[:name]).to eq('`speci!al#`@localhost')
    end
  end

  context 'using in-valid@localhost' do
    it 'should fail with an unquotted username with special char' do
      expect {
        Puppet::Type.type(:mysql_user).new(:name => 'in-valid@localhost', :password_hash => 'pass')
      }.to raise_error /Database user in-valid@localhost must be quotted/
    end
  end
end
