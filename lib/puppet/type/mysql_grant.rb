# frozen_string_literal: true

Puppet::Type.newtype(:mysql_grant) do
  @doc = <<-PUPPET
    @summary
      Manage a MySQL user's rights.
  PUPPET
  ensurable

  autorequire(:file) { '/root/.my.cnf' }
  autorequire(:mysql_user) { self[:user] }

  def initialize(*args)
    super
    # Forcibly munge any privilege with 'ALL' in the array to exist of just
    # 'ALL'.  This can't be done in the munge in the property as that iterates
    # over the array and there's no way to replace the entire array before it's
    # returned to the provider.
    self[:privileges] = 'ALL' if self[:ensure] == :present && Array(self[:privileges]).size > 1 && self[:privileges].to_s.include?('ALL')
    # Sort the privileges array in order to ensure the comparision in the provider
    # self.instances method match.  Otherwise this causes it to keep resetting the
    # privileges.
    # rubocop:disable Style/MultilineBlockChain
    self[:privileges] = Array(self[:privileges]).map { |priv|
                          # split and sort the column_privileges in the parentheses and rejoin
                          if priv.include?('(')
                            type, col = priv.strip.split(%r{\s+|\b}, 2)
                            "#{type.upcase} (#{col.slice(1...-1).strip.split(%r{\s*,\s*}).sort.join(', ')})"
                          else
                            priv.strip.upcase
                          end
                        }.uniq.reject { |k| ['GRANT', 'GRANT OPTION'].include?(k) }.sort!
  end
  # rubocop:enable Style/MultilineBlockChain
  validate do
    raise(_('mysql_grant: `privileges` `parameter` is required.')) if self[:ensure] == :present && self[:privileges].nil?
    raise(_('mysql_grant: `privileges` `parameter`: PROXY can only be specified by itself.')) if Array(self[:privileges]).size > 1 && Array(self[:privileges]).include?('PROXY')
    raise(_('mysql_grant: `table` `parameter` is required.')) if self[:ensure] == :present && self[:table].nil?
    raise(_('mysql_grant: `user` `parameter` is required.')) if self[:ensure] == :present && self[:user].nil?

    raise(_('mysql_grant: `name` `parameter` must match user@host/table format.')) if self[:user] && self[:table] && (self[:name] != "#{self[:user]}/#{self[:table]}")
  end

  newparam(:name, namevar: true) do
    desc 'Name to describe the grant.'

    munge do |value|
      value.delete("'")
    end
  end

  newproperty(:privileges, array_matching: :all) do
    desc 'Privileges for user'

    validate do |value|
      mysql_version = Facter.value(:mysql_version)
      if value =~ %r{proxy}i && Puppet::Util::Package.versioncmp(mysql_version, '5.5.0').negative?
        raise(ArgumentError, _('mysql_grant: PROXY user not supported on mysql versions < 5.5.0. Current version %{version}.') % { version: mysql_version })
      end
    end
  end

  newproperty(:table) do
    desc 'Table to apply privileges to.'

    validate do |value|
      if Array(@resource[:privileges]).include?('PROXY') && !%r{^[0-9a-zA-Z$_]*@[\w%.:\-/]*$}.match(value)
        raise(ArgumentError, _('mysql_grant: `table` `property` for PROXY should be specified as proxy_user@proxy_host.'))
      end
    end

    munge do |value|
      value.delete('`')
    end

    newvalues(%r{.*\..*}, %r{^[0-9a-zA-Z$_]*@[\w%.:\-/]*$})
  end

  newproperty(:user) do
    desc 'User to operate on.'
    validate do |value|
      # http://dev.mysql.com/doc/refman/5.5/en/identifiers.html
      # If at least one special char is used, string must be quoted
      # http://stackoverflow.com/questions/8055727/negating-a-backreference-in-regular-expressions/8057827#8057827
      # rubocop:disable Lint/AssignmentInCondition
      # rubocop:disable Lint/UselessAssignment
      if matches = %r{^(['`"])((?!\1).)*\1@([\w%.:\-/]+)$}.match(value)
        user_part = matches[2]
        host_part = matches[3]
      elsif matches = %r{^([0-9a-zA-Z$_]*)@([\w%.:\-/]+)$}.match(value) || matches = %r{^((?!['`"]).*[^0-9a-zA-Z$_].*)@(.+)$}.match(value)
        user_part = matches[1]
        host_part = matches[2]
      else
        raise(ArgumentError, _('mysql_grant: Invalid database user %{user}.') % { user: value })
      end
      # rubocop:enable Lint/AssignmentInCondition
      # rubocop:enable Lint/UselessAssignment
      mysql_version = Facter.value(:mysql_version)
      unless mysql_version.nil?
        raise(ArgumentError, _('mysql_grant: MySQL usernames are limited to a maximum of 16 characters.')) if Puppet::Util::Package.versioncmp(mysql_version, '5.7.8').negative? && user_part.size > 16
        raise(ArgumentError, _('mysql_grant: MySQL usernames are limited to a maximum of 32 characters.')) if Puppet::Util::Package.versioncmp(mysql_version, '10.0.0').negative? && user_part.size > 32
        raise(ArgumentError, _('mysql_grant: MySQL usernames are limited to a maximum of 80 characters.')) if Puppet::Util::Package.versioncmp(mysql_version, '10.0.0').positive? && user_part.size > 80
      end
    end

    munge do |value|
      matches = %r{^((['`"]?).*\2)@(.+)$}.match(value)
      "#{matches[1]}@#{matches[3].downcase}"
    end
  end

  newproperty(:options, array_matching: :all) do
    desc 'Options to grant.'
  end
end
