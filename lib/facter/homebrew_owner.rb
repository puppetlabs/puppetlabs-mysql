# homebrew_owner.rb

Facter.add('homebrew_owner') do
  confine :os do |os|
    os['family'] == 'Darwin'
  end
  setcode do
    Facter::Core::Execution.execute("/usr/bin/stat -nf '%Su' /usr/local/bin/brew")
  end
end
