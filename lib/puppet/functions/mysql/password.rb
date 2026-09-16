# frozen_string_literal: true

require 'digest/sha1'
require 'digest/sha2'
require 'openssl'
require 'base64'
# @summary
#   Password hashing as mysql / mariadb would do it. Defaults to native `PASSWORD()` like hashing.
#
Puppet::Functions.create_function(:'mysql::password') do
  # @param password
  #   Plain text password.
  # @param sensitive
  #   If the mysql password hash should be of datatype Sensitive[String]
  # @param hash
  #   Set type for password hash
  #
  #   Note: ed25519 does require gem openssl >= 3.2 meaning supported only with puppet >= 9
  # @param salt
  #   Use a specific salt value for caching_sha2_password
  #
  # @return hash
  #   The mysql password hash from the clear text password.
  #
  dispatch :password do
    required_param 'Variant[String, Sensitive[String]]', :password
    optional_param 'Boolean', :sensitive
    optional_param 'Enum["mysql_native_password", "caching_sha2_password", "ed25519"]', :hash
    optional_param 'String[20,20]', :salt
    return_type 'Variant[String, Sensitive[String]]'
  end

  def password(password, sensitive = false, hash = nil, salt = nil)
    password = password.unwrap if password.is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive)

    result_string = '' if password.empty?
    result_string ||= case hash
                      when 'mysql_native_password', nil # ensure default value when definded with nil
                        mysql_native_password(password)
                      when 'caching_sha2_password'
                        mysql_caching_sha2_password(password, salt)
                      when 'ed25519'
                        mysql_ed25519_password(password)
                      else
                        raise(Puppet::ParseError, "mysql::password(): got unkown hash type '#{hash}'")
                      end

    if sensitive
      Puppet::Pops::Types::PSensitiveType::Sensitive.new(result_string)
    else
      result_string
    end
  end

  def mysql_native_password(password)
    if %r{\A\*[A-F0-9]{40}\z}.match?(password)
      password
    else
      "*#{Digest::SHA1.hexdigest(Digest::SHA1.digest(password)).upcase}"
    end
  end

  def mysql_caching_sha2_password(password, _salt = nil)
    password = [password.delete_prefix('0x')].pack('H*') if %r{0x[A-F0-9]+}i.match?(password)
    if %r{\A\$[AB]\$[0-9A-Fa-f]{3}\$}n.match?(password) # rubocop:disable Style/GuardClause
      password
    else
      raise(Puppet::ParseError, 'mysql::password(): caching_sha2_password implementation is still TODO')
    end.unpack1('H*').upcase.prepend('0x')
  end

  def mysql_ed25519_password(password)
    if %r{\A[A-Za-z0-9+/]{43}\z}.match?(password)
      password
    else
      unless OpenSSL::PKey.respond_to?(:new_raw_private_key)
        raise(Puppet::ParseError, 'mysql::password(): ED25519 is only supported with gem openssl >= 3.2 (Puppet >= 9)')
      end
      Base64.strict_encode64(OpenSSL::PKey.new_raw_private_key('ED25519', OpenSSL::Digest::SHA512.digest(password)[0...32]).raw_public_key).delete('=')
    end
  end
end
