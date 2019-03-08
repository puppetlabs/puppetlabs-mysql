# homebrew_root_home.rb

Facter.add(:root_home) do
  confine :os do |os|
    os['family'] == 'Darwin'
  end
  setcode do
    local_owner = Facter::Core::Execution.execute("/usr/bin/stat -nf '%Su' /usr/local/bin/brew")
    str = Facter::Util::Resolution.exec("dscacheutil -q user -a name #{local_owner}")
    hash = {}
    str.split("\n").each do |pair|
      key, value = pair.split(%r{:})
      hash[key] = value
    end
    hash['dir'].strip
  end
end
