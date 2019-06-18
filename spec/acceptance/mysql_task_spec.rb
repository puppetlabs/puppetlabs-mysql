# run a test task
require 'spec_helper_acceptance'

describe 'mysql tasks', if: os[:family] != 'sles' do
  describe 'execute some sql' do
    pp = <<-MANIFEST
        class { 'mysql::server': root_password => 'password' }
        mysql::db { 'spec1':
          user     => 'root1',
          password => 'password',
        }
    MANIFEST

    it 'sets up a mysql instance' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'execute arbitary sql' do
      result = run_bolt_task('mysql::sql', 'sql' => 'show databases;', 'password' => 'password')
      expect(result.stdout).to contain(%r{information_schema})
      expect(result.stdout).to contain(%r{spec1})
    end
  end
end
