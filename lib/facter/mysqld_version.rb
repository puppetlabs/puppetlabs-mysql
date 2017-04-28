if version_string = Facter::Util::Resolution.exec('mysqld -V 2>/dev/null')
  # There are no consumers of this value with mysqld_type being defined as
  # a fact
  Facter.add('mysqld_version_string') do
    setcode version_string
  end

  Facter.add('mysqld_type') do
    setcode do
      # find the mysql "dialect" like mariadb / mysql etc.
      if version_string =~ %r{mariadb}i
        'mariadb'
      elsif version_string =~ %r{\s\(percona}i
        'percona'
      else
        'mysql'
      end
    end
  end

  Facter.add('mysqld_version') do
    setcode do
      # note: be prepared for '5.7.6-rc-log' etc results
      # versioncmp detects 5.7.6-log to be newer then 5.7.6 this is why we need
      # the trimming.
      version_string.match(%r{\d+\.\d+\.\d+})[0]
    end
  end
end
