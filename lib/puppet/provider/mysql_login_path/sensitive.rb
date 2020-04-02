# A Puppet Language type that makes the Sensitive Type comparable
#
class Puppet::Provider::MysqlLoginPath::Sensitive < Puppet::Pops::Types::PSensitiveType::Sensitive
  def ==(other)
    return true if other.is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive) && unwrap == other.unwrap
  end
end
