Puppet::Type.newtype(:database) do

  newparam(:name, :namevar => true) do
    desc 'Manage databases.'
    validate do |value|
      Puppet.warning("database has been deprecated in favor of mysql_database.")
      true
    end
  end

end
