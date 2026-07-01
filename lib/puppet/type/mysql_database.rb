# frozen_string_literal: true

Puppet::Type.newtype(:mysql_database) do
  @doc = <<-PUPPET
    @summary Manage a MySQL database.
  PUPPET

  ensurable

  autorequire(:file) { '/root/.my.cnf' }
  autorequire(:class) { 'mysql::server' }

  newparam(:name, namevar: true) do
    desc 'The name of the MySQL database to manage.'
  end

  # `utf8` is a deprecated alias for `utf8mb3` in both MySQL and MariaDB. Newer
  # servers (e.g. MariaDB 11 on RHEL 10) report the canonical `utf8mb3` name back,
  # while users typically request `utf8`. Treat the two spellings as equivalent so
  # the resource stays idempotent regardless of which the server reports. Charset
  # and collation names are case-insensitive and the server reports them
  # lowercased, so downcase first to also match user input such as `UTF8`.
  def self.normalise_utf8(value)
    value.to_s.downcase.sub(%r{^utf8mb3}, 'utf8')
  end

  newproperty(:charset) do
    desc 'The CHARACTER SET setting for the database'
    defaultto :utf8
    newvalue(%r{^\S+$})

    def insync?(is)
      resource.class.normalise_utf8(is) == resource.class.normalise_utf8(should)
    end
  end

  newproperty(:collate) do
    desc 'The COLLATE setting for the database'
    defaultto :utf8_general_ci
    newvalue(%r{^\S+$})

    def insync?(is)
      resource.class.normalise_utf8(is) == resource.class.normalise_utf8(should)
    end
  end
end
