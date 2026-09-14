# frozen_string_literal: true

require 'digest'

module Puppet
  # MySQL password hashing utilities
  module MysqlHasher
    # Printable ASCII characters excluding $ for salt generation
    SALT_CHARS = (0x20..0x7E).to_a.map(&:chr).freeze - ['$']
    SALT_CHARS.freeze

    # Base64-like characters for crypt encoding
    CRYPT_CHARS = (['.', '/'] + ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a).freeze

    # Generate MySQL caching_sha2_password hash in expected hex format
    # @param password [String] The plain text password to hash
    # @param salt [String, nil] Optional salt (20 bytes). If not provided, a deterministic salt is generated
    # @return [String] The MySQL caching_sha2_password hash in hex format (with 0x prefix)
    def self.caching_sha2_password(password, salt: nil)
      return password if password =~ /^0x[A-F0-9]+$/i

      validate_password(password)

      if salt.nil?
        salt = generate_deterministic_salt(password)
      else
        raise ArgumentError, "salt must be exactly 20 bytes (got #{salt.bytesize})" unless salt.bytesize == 20
      end

      count = 5
      iterations = 1000 * count

      digest = sha_crypts(password, salt, iterations)

      # Format: $A$005${salt}{digest}
      auth_string = "$A$#{sprintf('%03d', count)}$#{salt}#{digest}"

      hex_result = auth_string.unpack1('H*').upcase
      "0x#{hex_result}"
    end

    def self.validate_password(password)
      raise ArgumentError, 'Password cannot be empty' if password.nil? || password.empty?
      raise ArgumentError, 'Password too long (max 1000 bytes)' if password.bytesize > 1000
    end

    # Generate deterministic salt to ensure idempotency
    def self.generate_deterministic_salt(password)
      hash_bytes = Digest::SHA256.digest(password)

      salt = String.new(capacity: 20)
      20.times do |i|
        byte_value = hash_bytes[i].ord
        salt << SALT_CHARS[byte_value % SALT_CHARS.length]
      end
      salt
    end

    # Base64-like encoding used in crypt
    def self.to64(value, length)
      result = String.new(capacity: length)

      length.times do
        result << CRYPT_CHARS[value & 0x3F]
        value >>= 6
      end

      result
    end

    # SHA-256 crypt algorithm implementation
    def self.sha_crypts(password, salt, iterations)
      bytes = 32

      b = Digest::SHA256.digest(password + salt + password)

      tmp = String.new(capacity: 256)
      tmp << password << salt

      i = password.length
      while i > 0
        if i > bytes
          tmp << b
          i -= bytes
        else
          tmp << b[0, i]
          break
        end
      end

      i = password.length
      while i > 0
        tmp << ((i & 1) != 0 ? b : password)
        i >>= 1
      end

      a = Digest::SHA256.digest(tmp)

      tmp = password * password.length
      dp = Digest::SHA256.digest(tmp)

      p = String.new(capacity: password.length)
      i = password.length
      while i > 0
        if i > bytes
          p << dp
          i -= bytes
        else
          p << dp[0, i]
          break
        end
      end

      tmp = salt * (16 + a[0].ord)
      ds = Digest::SHA256.digest(tmp)

      s = String.new(capacity: salt.length)
      i = salt.length
      while i > 0
        if i > bytes
          s << ds
          i -= bytes
        else
          s << ds[0, i]
          break
        end
      end

      c = a
      iterations.times do |idx|
        tmp = (idx & 1) != 0 ? p.dup : c.dup
        tmp << s if (idx % 3) != 0
        tmp << p if (idx % 7) != 0
        tmp << ((idx & 1) != 0 ? c : p)

        c = Digest::SHA256.digest(tmp)
      end

      result = String.new(capacity: 43)
      i = 0

      loop do
        val = (c[i].ord << 16) | (c[(i + 10) % 30].ord << 8) | c[(i + 20) % 30].ord
        result << to64(val, 4)
        i = (i + 21) % 30
        break if i == 0
      end

      val = (c[31].ord << 8) | c[30].ord
      result << to64(val, 3)

      result
    end
  end
end
