def pre_run
  apply_manifest("class { 'mysql::server': root_password => 'password' }", catch_failures: true)
  @mysql_version = (on default, 'mysql --version').output.chomp.match(%r{\d+\.\d+\.\d+})[0]
end

def version_is_greater_than(version)
  Puppet::Util::Package.versioncmp(@mysql_version, version) > 0
end

def check_script_output(result:, match:, stderr: be_empty, exit_code: be_zero)
  expect(result.stdout).to match(%r{#{match}})
  expect(result.exit_code).to exit_code
  expect(result.stderr).to stderr
end
