require 'spec_helper_system'

describe 'mysql::db define' do
  describe 'creating a database' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'mysql': root_password => 'password', }
        class { 'mysql::server': }
        mysql::db { 'spec1':
          user     => 'root',
          password => 'password',
        }
      EOS

      # Run it twice and test for idempotency
      puppet_apply(pp) do |r|
        [0,2].should include r.exit_code
        r.refresh
        r.exit_code.should be_zero
      end
    end

    it 'should have the database' do
      shell("mysql -e 'show databases;'|grep spec1") do |s|
        s.exit_code.should be_zero
      end
    end
  end

  describe 'creating a database with post-sql' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'mysql': root_password => 'password', }
        class { 'mysql::server': }
        file { '/tmp/spec.sql':
          ensure  => file,
          content => 'CREATE TABLE table1 (id int);',
          before  => Mysql::Db['spec2'],
        }
        mysql::db { 'spec2':
          user     => 'root',
          password => 'password',
          sql      => '/tmp/spec.sql',
        }
      EOS

      # Run it twice and test for idempotency
      puppet_apply(pp) do |r|
        [0,2].should include r.exit_code
        r.refresh
        r.exit_code.should be_zero
      end
    end

    it 'should have the table' do
      shell("mysql -e 'show tables;' spec2|grep table1") do |s|
        s.exit_code.should == 0
      end
    end
  end
end
