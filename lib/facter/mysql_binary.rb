# frozen_string_literal: true

Facter.add('mysql_binary') do
  setcode do
    if Facter::Core::Execution.which('mariadb')
      'mariadb'
    elsif Facter::Core::Execution.which('mysql')
      'mysql'
    end
  end
end
