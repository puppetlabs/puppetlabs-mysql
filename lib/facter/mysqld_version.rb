Facter.add("mysqld_version") do
  setcode do
    Facter::Util::Resolution.exec('mysqld -V')
  end
end
