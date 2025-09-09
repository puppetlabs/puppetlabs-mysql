# frozen_string_literal: true
require 'digest'
require 'securerandom'

# @summary
#   Generate MySQL caching_sha2_password hash in expected hex format

Puppet::Functions.create_function(:caching_sha2_password) do
  # @param password
  #   The plain text password to hash
  # @param salt
  #   Optional salt (20 bytes). If not provided, a random salt is generated it needs to be exactly 20 bytes
  # @return String
  #   The MySQL caching_sha2_password hash in hex format (with lowercase 0x prefix)

  dispatch :generate_hash do
    param 'String', :password
    optional_param 'String', :salt
    return_type 'String'
  end

  def generate_hash(password, salt = nil)
    validate_password(password)

    # Generate random 20-byte UTF-8 compatible salt if not provided
    if salt.nil?
      salt = generate_utf8_salt(20)
    else
      raise ArgumentError, "salt must be exactly 20 bytes (got #{salt.bytesize})" unless salt.bytesize == 20
    end

    # Generate the hash using SHA-256 crypt algorithm
    count = 5
    iterations = 1000 * count

    digest = sha_crypts(password, salt, iterations)

    # Format: $A$005${salt}{digest} - note: literal $ characters, not escaped
    auth_string = "$A$#{sprintf('%03d', count)}$#{salt}#{digest}"

    # Convert to hex and add 0x prefix
    hex_result = auth_string.unpack1('H*').upcase
    "0x#{hex_result}"

  rescue => e
    raise Puppet::ParseError, "Failed to generate MySQL password hash: #{e.message}"
  end

  private

  def validate_password(password)
    raise Puppet::ParseError, "Password cannot be empty" if password.nil? || password.empty?
    raise Puppet::ParseError, "Password too long (max 1000 bytes)" if password.bytesize > 1000
  end

  # Generate UTF-8 compatible salt (printable ASCII chars, avoiding $)
  def generate_utf8_salt(length)
    chars = (0x20..0x7E).to_a.map(&:chr) - ['$']
    length.times.map { chars.sample }.join
  end

  # Base64-like encoding used in crypt
  def to64(value, length)
    chars = ['.', '/'] + ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a
    result = ''

    length.times do
      result += chars[value & 0x3F]
      value >>= 6
    end

    result
  end

  # SHA-256 crypt algorithm implementation
  def sha_crypts(password, salt, iterations)
    bytes = 32  # SHA-256 produces 32 bytes

    # Initial hash: password + salt + password
    b = Digest::SHA256.digest(password + salt + password)

    # Build intermediate value
    tmp = password + salt

    # Add alternate sum for each character in password
    i = password.length
    while i > 0
      if i > bytes
        tmp += b
        i -= bytes
      else
        tmp += b[0, i]
        break
      end
    end

    # Process password length bits
    i = password.length
    while i > 0
      if (i & 1) != 0
        tmp += b
      else
        tmp += password
      end
      i >>= 1
    end

    a = Digest::SHA256.digest(tmp)

    # Create DP (password sequence)
    tmp = password * password.length
    dp = Digest::SHA256.digest(tmp)

    # Create P sequence
    p = ''
    i = password.length
    while i > 0
      if i > bytes
        p += dp
        i -= bytes
      else
        p += dp[0, i]
        break
      end
    end

    # Create DS (salt sequence)
    tmp = salt * (16 + a[0].ord)
    ds = Digest::SHA256.digest(tmp)

    # Create S sequence
    s = ''
    i = salt.length
    while i > 0
      if i > bytes
        s += ds
        i -= bytes
      else
        s += ds[0, i]
        break
      end
    end

    # Main iteration loop
    c = a
    iterations.times do |i|
      if (i & 1) != 0
        tmp = p
      else
        tmp = c
      end

      tmp += s if (i % 3) != 0
      tmp += p if (i % 7) != 0

      if (i & 1) != 0
        tmp += c
      else
        tmp += p
      end

      c = Digest::SHA256.digest(tmp)
    end

    # Final encoding for SHA-256
    result = ''
    i = 0

    # Process in groups of 3 bytes
    loop do
      val = (c[i].ord << 16) | (c[(i + 10) % 30].ord << 8) | c[(i + 20) % 30].ord
      result += to64(val, 4)
      i = (i + 21) % 30
      break if i == 0
    end

    # Handle remaining bytes
    val = (c[31].ord << 8) | c[30].ord
    result += to64(val, 3)

    result
  end
end
