# This has to be a separate type to enable collecting
Puppet::Type.newtype(:mysql_user) do
  @doc = 'Manage a MySQL user. This includes management of users password as well as privileges.'

  ensurable

  autorequire(:file) { '/root/.my.cnf' }
  autorequire(:class) { 'mysql::server' }

  validate do
    if !self[:ssl_cipher].empty? and self[:ssl_type] != 'SPECIFIED'
      fail ArgumentError, "Specifying a SSL cipher requires SSL-type 'SPECIFIED'"
    end
  end

  newparam(:name, :namevar => true) do
    desc "The name of the user. This uses the 'username@hostname' or username@hostname."
    validate do |value|
      # http://dev.mysql.com/doc/refman/5.5/en/identifiers.html
      # If at least one special char is used, string must be quoted

      # http://stackoverflow.com/questions/8055727/negating-a-backreference-in-regular-expressions/8057827#8057827
      if matches = /^(['`"])((?:(?!\1).)*)\1@([\w%\.:\-\/]+)$/.match(value)
        user_part = matches[2]
        host_part = matches[3]
      elsif matches = /^([0-9a-zA-Z$_]*)@([\w%\.:\-\/]+)$/.match(value)
        user_part = matches[1]
        host_part = matches[2]
      elsif matches = /^((?!['`"]).*[^0-9a-zA-Z$_].*)@(.+)$/.match(value)
        user_part = matches[1]
        host_part = matches[2]
      else
        raise(ArgumentError, "Invalid database user #{value}")
      end

      mysql_version = Facter.value(:mysql_version)
      unless mysql_version.nil?
        if Puppet::Util::Package.versioncmp(mysql_version, '10.0.0') < 0 and user_part.size > 16
          raise(ArgumentError, 'MySQL usernames are limited to a maximum of 16 characters')
        elsif Puppet::Util::Package.versioncmp(mysql_version, '10.0.0') > 0 and user_part.size > 80
          raise(ArgumentError, 'MySQL usernames are limited to a maximum of 80 characters')
        end
      end
    end

    munge do |value|
      matches = /^((['`"]?).*\2)@(.+)$/.match(value)
      "#{matches[1]}@#{matches[3].downcase}"
    end
  end

  newproperty(:password_hash) do
    desc 'The password hash of the user. Use mysql_password() for creating such a hash.'
    newvalue(/\w*/)
  end

  newproperty(:plugin) do
    desc 'The authentication plugin of the user.'
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

  newproperty(:ssl_type) do
    desc "SSL-type the user has to use to connect. Can be any of '', 'ANY', 'SPECIFIED', 'X509'."
    newvalues('', 'ANY', 'SPECIFIED', 'X509')
    defaultto ''
    munge do |value|
      String(value).upcase
    end
  end

  newproperty(:ssl_cipher) do
    desc "SSL-cipher the user has to use to connect. Requires ssl-type='SPECIFIED'."
    newvalue(/\w*/)
    defaultto ''
    munge do |value|
      String(value)
    end
  end

end
