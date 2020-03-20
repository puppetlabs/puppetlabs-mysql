# frozen_string_literal: true

require 'puppet'
require 'puppet/type/mysql_login_path'

describe Puppet::Type.type(:mysql_login_path) do
  it 'loads' do
    expect(Puppet::Type.type(:mysql_login_path)).not_to be_nil
  end

  it 'requires a name' do
    expect {
      Puppet::Type.type(:mysql_login_path).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  context 'using login path with socket' do
    let(:login_path) { Puppet::Type.type(:mysql_login_path).new(
        name: 'local_socket',
        host: 'localhost',
        user: 'root',
        password: Puppet::Pops::Types::PSensitiveType::Sensitive.new('secure'),
        socket: '/var/run/mysql/mysql.sock')
    }

    it 'accepts a name' do
      login_path[:name] = 'local_socket'
      expect(login_path[:name]).to eq('local_socket')
    end

    it 'accepts a host' do
      login_path[:host] = '10.0.0.1'
      expect(login_path[:host]).to eq('10.0.0.1')
    end

    it 'accepts a user' do
      login_path[:user] = 'user1'
      expect(login_path[:user]).to eq('user1')
    end

    it 'accepts a password' do
      login_path[:password] = Puppet::Pops::Types::PSensitiveType::Sensitive.new('even_more_secure')
      expect(login_path[:password].unwrap).to eq('even_more_secure')
    end

  end

  context 'using login path with tcp' do
    let(:login_path) { Puppet::Type.type(:mysql_login_path).new(
        name: 'local_tcp',
        host: '127.0.0.1',
        user: 'root',
        password: Puppet::Pops::Types::PSensitiveType::Sensitive.new('secure'),
        port: 3306)
    }

    it 'accepts a port' do
      login_path[:port] = 3307
      expect(login_path[:port]).to eq(3307)
    end
  end
end
