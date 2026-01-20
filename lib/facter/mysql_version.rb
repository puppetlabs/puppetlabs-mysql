# frozen_string_literal: true

Facter.add('mysql_version') do
  setcode do
    mysql_ver = if Facter::Core::Execution.which('mysql')
                  Facter::Core::Execution.execute('mysql --version')
                elsif Facter::Core::Execution.which('mariadb')
                  Facter::Core::Execution.execute('mariadb --version')
                end
    mysql_ver.match(%r{\d+\.\d+\.\d+})[0] if mysql_ver
  end
end
