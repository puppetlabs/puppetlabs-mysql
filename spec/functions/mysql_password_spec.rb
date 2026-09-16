# frozen_string_literal: true

require 'spec_helper'

shared_examples 'mysql::password function' do
  it 'exists' do
    expect(subject).not_to be_nil
  end

  it 'raises a ArgumentError if there is less than 1 arguments' do
    expect(subject).to run.with_params.and_raise_error(ArgumentError)
  end

  it 'raises a ArgumentError if there is more than 4 arguments' do
    expect(subject).to run.with_params('foo', false, 'mysql_native_password', 'aaaaaaaaaaaaaaaaaaaa', 'blub').and_raise_error(ArgumentError)
  end

  it 'converts password into a hash' do
    expect(subject).to run.with_params('password').and_return('*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19')
  end

  it 'accept password as Sensitive' do
    expect(subject).to run.with_params(sensitive('password')).and_return('*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19')
  end

  it 'returns Sensitive with sensitive=true' do
    expect(subject).to run.with_params('password', true).and_return(sensitive('*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19'))
  end

  it 'password should be String' do
    expect(subject).to run.with_params(123).and_raise_error(ArgumentError)
  end

  it 'converts an empty password into a empty string' do
    expect(subject).to run.with_params('').and_return('')
  end

  it 'converts the password when its given in caps with * sign' do
    expect(subject).to run.with_params('AFDJKFD1*94BDCEBE19083CE2A1F959FD02F964C7AF4CFC29').and_return('*91FF6DD4E1FC57D2EFC57F49552D0596F7D46BAF')
  end

  it 'does not convert a password that is already a hash' do
    expect(subject).to run.with_params('*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19').and_return('*2470C0C06DEE42FD1618BB99005ADCA2EC9D1E19')
  end

  context 'should work with caching_sha2_password' do
    it 'converts password into a hash' do
      expect(subject).to run
        .with_params('password', false, 'caching_sha2_password')
        .and_raise_error(Puppet::ParseError, 'mysql::password(): caching_sha2_password implementation is still TODO')
    end

    it 'accept password as Sensitive' do
      expect(subject).to run
        .with_params(sensitive('password'), false, 'caching_sha2_password')
        .and_raise_error(Puppet::ParseError, 'mysql::password(): caching_sha2_password implementation is still TODO')
    end

    it 'returns Sensitive with sensitive=true' do
      expect(subject).to run
        .with_params('password', true, 'caching_sha2_password')
        .and_raise_error(Puppet::ParseError, 'mysql::password(): caching_sha2_password implementation is still TODO')
    end

    it 'converts an empty password into a empty string' do
      expect(subject).to run.with_params('', false, 'caching_sha2_password').and_return('')
    end

    it 'does not convert a password that is already a hash' do
      expect(subject).to run
        .with_params(
          '0x24412430303524535636474D65423832324C49454C7950424F51386241354D786F6B35717A707435334A7463736D7174366A6B7861645965354854452F6E476A4A414A717134556D50365A43',
          false,
          'caching_sha2_password',
        )
        .and_return('0x24412430303524535636474D65423832324C49454C7950424F51386241354D786F6B35717A707435334A7463736D7174366A6B7861645965354854452F6E476A4A414A717134556D50365A43')
    end
  end

  context 'should work with ed25519' do
    it 'converts password into a hash' do
      unless OpenSSL::PKey.respond_to?(:new_raw_private_key)
        skip('Requries OpenSSL >= 3.2 gem comming with Puppet 9')
      end
      expect(subject).to run.with_params('secret', false, 'ed25519').and_return('ZIgUREUg5PVgQ6LskhXmO+eZLS0nC8be6HPjYWR4YJY')
    end

    it 'accept password as Sensitive' do
      unless OpenSSL::PKey.respond_to?(:new_raw_private_key)
        skip('Requries OpenSSL >= 3.2 gem comming with Puppet 9')
      end
      expect(subject).to run.with_params(sensitive('secret'), false, 'ed25519').and_return('ZIgUREUg5PVgQ6LskhXmO+eZLS0nC8be6HPjYWR4YJY')
    end

    it 'returns Sensitive with sensitive=true' do
      unless OpenSSL::PKey.respond_to?(:new_raw_private_key)
        skip('Requries OpenSSL >= 3.2 gem comming with Puppet 9')
      end
      expect(subject).to run.with_params('secret', true, 'ed25519').and_return(sensitive('ZIgUREUg5PVgQ6LskhXmO+eZLS0nC8be6HPjYWR4YJY'))
    end

    it 'converts an empty password into a empty string' do
      expect(subject).to run.with_params('', false, 'ed25519').and_return('')
    end

    it 'does not convert a password that is already a hash' do
      expect(subject).to run.with_params('ZIgUREUg5PVgQ6LskhXmO+eZLS0nC8be6HPjYWR4YJY', false, 'ed25519')
                            .and_return('ZIgUREUg5PVgQ6LskhXmO+eZLS0nC8be6HPjYWR4YJY')
    end
  end
end

describe 'mysql::password' do
  it_behaves_like 'mysql::password function'

  describe 'non-namespaced shim' do
    describe 'mysql_password', type: :puppet_function do
      it_behaves_like 'mysql::password function'
    end
  end
end
