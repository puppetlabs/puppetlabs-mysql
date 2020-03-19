
class Puppet::Provider::MysqlLoginPath::Sensitive < Puppet::Pops::Types::PSensitiveType::Sensitive
  def ==(other_object)
    if other_object.is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive)
      if self.unwrap == other_object.unwrap
        return true
      end
    end
  end
end