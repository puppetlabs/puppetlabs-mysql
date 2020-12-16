# frozen_string_literal: true

Facter.add('mysql_version') do
  confine { Facter::Core::Execution.which('mysql') }
  setcode do
    mysql_ver = Facter::Util::Resolution.exec('mysql --version')
    mysql_ver.match(%r{\d+\.\d+\.\d+})[0] if mysql_ver
  end
end
