# frozen_string_literal: true

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
  end
end
