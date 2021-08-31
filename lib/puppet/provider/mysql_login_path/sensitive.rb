# frozen_string_literal: true

# A Puppet Language type that makes the Sensitive Type comparable
#
class Puppet::Provider::MysqlLoginPath::Sensitive < Puppet::Pops::Types::PSensitiveType::Sensitive
  def ==(other)
    return true if other.is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive) && unwrap == other.unwrap
  end

  def encode_with(coder)
    coder.tag = nil
    coder.scalar = 'Puppet::Provider::MysqlLoginPath::Sensitive <<encrypted>>'
  end
end
