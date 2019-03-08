# homebrew_group.rb

Facter.add('homebrew_group') do
  confine :os do |os|
    os['family'] == 'Darwin'
  end
  setcode do
    Facter::Core::Execution.execute("/usr/bin/stat -nf '%Sg' /usr/local/bin/brew")
  end
end
