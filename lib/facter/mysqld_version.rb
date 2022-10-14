# frozen_string_literal: true

Facter.add('mysqld_version') do
  confine { Facter::Core::Execution.which('mysqld') }
  setcode do
    Facter::Core::Execution.execute('mysqld --no-defaults -V 2>/dev/null')
  end
end
