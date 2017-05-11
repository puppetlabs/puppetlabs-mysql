class Puppet::Provider::Noop < Puppet::Provider

  def create
    true
  end

  def destroy
    true
  end

  def exists?
    false
  end

end
