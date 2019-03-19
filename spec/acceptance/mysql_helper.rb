def pre_run
  apply_manifest("class { 'mysql::server': root_password => 'password' }", catch_failures: true)
  shell_output = run_shell('mysql --version')
  @mysql_version = shell_output.first['result']['stdout'].match(%r{\d+\.\d+\.\d+})[0]
end

def mysql_version_is_greater_than(version)
  return true if Gem::Version.new(@mysql_version) > Gem::Version.new(version)
  false
end
