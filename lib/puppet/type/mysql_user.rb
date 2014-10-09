# This has to be a separate type to enable collecting
Puppet::Type.newtype(:mysql_user) do
  @doc = 'Manage a MySQL user. This includes management of users password as well as privileges.'

  ensurable

  autorequire(:file) { '/root/.my.cnf' }

  newparam(:name, :namevar => true) do
    desc "The name of the user. This uses the 'username@hostname' or username@hostname."
    validate do |value|
      # http://dev.mysql.com/doc/refman/5.5/en/identifiers.html
      # Regex should problably be more like this: /^[`'"]?[^`'"]*[`'"]?@[`'"]?[\w%\.]+[`'"]?$/
      # If at least one special char is used, string must be quoted
      raise(ArgumentError, "Database user #{value} must be quotted as it contains special characters") if value =~ /^[^'`"].*[^0-9a-zA-Z$_].*[^'`"]@[\w%\.:]+/
      # If no special char, quoted is not needed, but allowed
      # I don't see any case where this could happen, as it should be covered by previous check
      raise(ArgumentError, "Invalid database user #{value}") unless value =~ /^['`"]?[0-9a-zA-Z$_]*['`"]?@[\w%\.:]+/
      username = value.split('@')[0]
      if username.size > 16
        raise ArgumentError, 'MySQL usernames are limited to a maximum of 16 characters'
      end
    end

    munge do |value|
      user_part, host_part = value.split('@')
      "#{user_part}@#{host_part.downcase}"
    end
  end

  newproperty(:password_hash) do
    desc 'The password hash of the user. Use mysql_password() for creating such a hash.'
    newvalue(/\w+/)
  end

  newproperty(:max_user_connections) do
    desc "Max concurrent connections for the user. 0 means no (or global) limit."
    newvalue(/\d+/)
  end

  newproperty(:max_connections_per_hour) do
    desc "Max connections per hour for the user. 0 means no (or global) limit."
    newvalue(/\d+/)
  end

  newproperty(:max_queries_per_hour) do
    desc "Max queries per hour for the user. 0 means no (or global) limit."
    newvalue(/\d+/)
  end

  newproperty(:max_updates_per_hour) do
    desc "Max updates per hour for the user. 0 means no (or global) limit."
    newvalue(/\d+/)
  end

end
