require 'puppet'
require 'puppet/type/database_user'
describe Puppet::Type.type(:database_user) do

    let :params do
        {
            :password_hash => 'pass',
        }
    end

    it 'should require a name' do
        expect {
            Puppet::Type.type(:database_user).new({})
        }.to raise_error(Puppet::Error, 'Title or name must be provided')
    end

    context 'with a valid user@hostname' do
        before :each do
            params.merge!({ :name => "foo@localhost" })
        end

        it 'should accept a user name' do
            resource = Puppet::Type.type(:database_user).new(params)
            resource[:name].should == 'foo@localhost'
        end

        it 'should accept a password' do
            resource = Puppet::Type.type(:database_user).new(params)
            resource[:password_hash] = 'foo'
            resource[:password_hash].should == 'foo'
        end

    end

    context 'with a long username' do
        before :each do
            params.merge!({ :name => "12345678901234567@localhost" })
        end

        it 'should fail with a long user name' do
            expect {
                resource = Puppet::Type.type(:database_user).new(params)
            }.to raise_error(/MySQL usernames are limited to a maximum of 16 characters/)
        end
    end

    context 'with a valid user@' do
        before :each do
            params.merge!({ :name => "foo@" })
        end

        it 'should accept a user name' do
            resource = Puppet::Type.type(:database_user).new(params)
            resource[:name].should == 'foo@'
        end
    end

    context 'with an invalid user' do
        before :each do
            params.merge!({ :name => "foo" })
        end

        it 'should fail without a hostname' do
            expect {
                resource = Puppet::Type.type(:database_user).new(params)
            }.to raise_error(/Invalid database user foo/)
        end
    end

end
