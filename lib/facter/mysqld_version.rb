Facter.add('mysqld_version') do
  confine { Facter::Core::Execution.which('mysqld') }
  setcode do
    Facter::Util::Resolution.exec('mysqld --no-defaults -V 2>/dev/null')
  end
end
