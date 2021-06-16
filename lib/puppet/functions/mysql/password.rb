# frozen_string_literal: true

require 'digest/sha1'
# @summary
#   Hash a string as mysql's "PASSWORD()" function would do it
#
Puppet::Functions.create_function(:'mysql::password') do
  # @param password
  #   Plain text password.
  # @param sensitive
  #   If the Postgresql-Passwordhash should be of Datatype Sensitive[String]
  #
  # @return hash
  #   The mysql password hash from the clear text password.
  #
  dispatch :password do
    required_param 'Variant[String, Sensitive[String]]', :password
    optional_param 'Boolean', :sensitive
    return_type 'Variant[String, Sensitive[String]]'
  end

  def password(password, sensitive = false)
    if password.is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive)
      password = password.unwrap
    end

    result_string = if %r{\*[A-F0-9]{40}$}.match?(password)
                      password
                    elsif password.empty?
                      ''
                    else
                      '*' + Digest::SHA1.hexdigest(Digest::SHA1.digest(password)).upcase
                    end

    if sensitive
      Puppet::Pops::Types::PSensitiveType::Sensitive.new(result_string)
    else
      result_string
    end
  end
end
