Puppet::Type.newtype(:database_user) do

  newparam(:name, :namevar => true) do
    desc 'Manage database users.'
    validate do |value|
      Puppet.warning("database_user has been deprecated in favor of mysql_user.")
      true
    end
  end

end
