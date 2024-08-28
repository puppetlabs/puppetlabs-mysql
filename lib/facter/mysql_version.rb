# frozen_string_literal: true

Facter.add('mysql_version') do
  confine { Facter::Core::Execution.which('mysql') }
  setcode do
    mysql_ver = Facter::Core::Execution.execute('mysql --version')
    mysql_ver.match(%r{\d+\.\d+\.\d+})[0] if mysql_ver
  end
end

Facter.add('mysql_version') do
  confine { Facter::Core::Execution.which('mariadb') }
  setcode do
    mysql_ver = Facter::Core::Execution.execute('mariadb --version')
    mysql_ver.match(%r{\d+\.\d+\.\d+})[0] if mysql_ver
  end
end
