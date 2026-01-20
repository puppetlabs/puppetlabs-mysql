# frozen_string_literal: true
require_relative '../../mysql_hasher'

# @summary
#   Generate MySQL caching_sha2_password hash in expected hex format or return already hashed password

Puppet::Functions.create_function(:caching_sha2_password) do
  # @param password
  #   The plain text password to hash or an already hashed password (starting with 0x)
  # @param salt
  #   Optional salt (20 bytes). If not provided, a deterministic salt is generated
  # @param username
  #   Optional username for deterministic salt generation
  # @return String
  #   The MySQL caching_sha2_password hash in hex format (with 0x prefix)

  dispatch :generate_hash do
    param 'String', :password
    optional_param 'String', :salt
    optional_param 'String', :username
    return_type 'String'
  end

  def generate_hash(password, salt = nil, username = nil)
    Puppet::MysqlHasher.caching_sha2_password(password, salt, username)
  rescue => e
    raise Puppet::ParseError, "Failed to generate MySQL password hash: #{e.message}"
  end
end
