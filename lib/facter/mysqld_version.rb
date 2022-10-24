# frozen_string_literal: true

Facter.add('mysqld_version') do
  confine { Facter::Core::Execution.which('mysqld') || Facter::Core::Execution.which('/usr/libexec/mysqld') }
  setcode do
    # Add /usr/libexec to PATH to find mysqld command
    Facter::Core::Execution.execute('env PATH=$PATH:/usr/libexec mysqld --no-defaults -V 2>/dev/null')
  end
end
