# This has to be a separate type to enable collecting
Puppet::Type.newtype(:database_grant) do
  @doc = "Manage a database user's rights."
  ensurable

  autorequire :database do
    # puts "Starting db autoreq for %s" % self[:name]
    reqs = []
    matches = self[:name].match(/^([^@]+)@([^\/]+)\/(.+)$/)
    unless matches.nil?
      reqs << matches[3]
    end
    # puts "Autoreq: '%s'" % reqs.join(" ")
    reqs
  end

  autorequire :database_user do
    # puts "Starting user autoreq for %s" % self[:name]
    reqs = []
    matches = self[:name].match(/^([^@]+)@([^\/]+).*$/)
    unless matches.nil?
      reqs << "%s@%s" % [ matches[1], matches[2] ]
    end
    # puts "Autoreq: '%s'" % reqs.join(" ")
    reqs
  end

  newparam(:name) do
    desc "The primary key: either user@host for global privilges or user@host/database for database specific privileges"
  end

  newproperty(:privileges, :array_matching => :all) do
    desc "The privileges the user should have. The possible values are implementation dependent."

    munge do |v|
      symbolize v
      symbolize v
    end

    def is_to_s(i_val = @is)
      if i_val
        i_val.to_a.map { |v| v.to_s }.sort.inspect
      else
        nil
      end
    end

    def should_to_s(s_val = @should)
      if s_val
        s_val.to_a.map { |v| v.to_s }.sort.inspect
      else
        nil
      end
    end

    def insync?(is)
      if defined?(@should) and @should
        is_privs = self.provider.privileges.map{|v| v.to_s}.sort.inspect
        is_privs == self.should_to_s
      else
        true
      end
    end

  end
end
