require 'spec_helper_system'

describe 'mysql_grant' do

  describe 'setup' do
    it 'setup mysql::server' do
      pp = <<-EOS
        class { 'mysql::server': }
      EOS

      puppet_apply(pp)
    end
  end

  describe 'missing privileges for user' do
    it 'should fail' do
      pp = <<-EOS
        mysql_grant { 'test@tester/test.*':
          ensure => 'present',
          table  => 'test.*',
          user   => 'test@tester',
        }
      EOS

      puppet_apply(pp) do |r|
        r.stderr.should =~ /privileges parameter is required/
      end
    end

    it 'should not find the user' do
      shell("mysql -NBe \"SHOW GRANTS FOR test@tester\"") do |r|
        r.stderr.should =~ /There is no such grant defined for user 'test' on host 'tester'/
        r.exit_code.should eq 1
      end
    end
  end

  describe 'missing table for user' do
    it 'should fail' do
      pp = <<-EOS
        mysql_grant { 'atest@tester/test.*':
          ensure => 'present',
          user   => 'atest@tester',
          privileges => ['ALL'],
        }
      EOS

      puppet_apply(pp) do |r|
        r.exit_code.should eq 4
      end
    end

    it 'should not find the user' do
      shell("mysql -NBe \"SHOW GRANTS FOR atest@tester\"") do |r|
        r.stderr.should =~ /There is no such grant defined for user 'atest' on host 'tester'/
        r.exit_code.should eq 1
      end
    end
  end

  describe 'adding privileges' do
    it 'should work without errors' do
      pp = <<-EOS
        mysql_grant { 'test@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@tester',
          privileges => ['SELECT', 'UPDATE'],
        }
      EOS

      puppet_apply(pp)
    end

    it 'should find the user' do
      shell("mysql -NBe \"SHOW GRANTS FOR test@tester\"") do |r|
        r.stdout.should =~ /GRANT SELECT, UPDATE.*TO 'test'@'tester'/
        r.stderr.should be_empty
        r.exit_code.should be_zero
      end
    end
  end

  describe 'adding option' do
    it 'should work without errors' do
      pp = <<-EOS
        mysql_grant { 'test@tester/test.*':
          ensure  => 'present',
          table   => 'test.*',
          user    => 'test@tester',
          options => ['GRANT'],
          privileges => ['SELECT', 'UPDATE'],
        }
      EOS

      puppet_apply(pp)
    end

    it 'should find the user' do
      shell("mysql -NBe \"SHOW GRANTS FOR test@tester\"") do |r|
        r.stdout.should =~ /GRANT SELECT, UPDATE ON `test`.* TO 'test'@'tester' WITH GRANT OPTION$/
        r.stderr.should be_empty
        r.exit_code.should be_zero
      end
    end
  end


  describe 'adding all privileges' do
    it 'should only try to apply ALL' do
      pp = <<-EOS
        mysql_grant { 'test@tester/test.*':
          ensure     => 'present',
          table      => 'test.*',
          user       => 'test@tester',
          options    => ['GRANT'],
          privileges => ['SELECT', 'UPDATE', 'ALL'],
        }
      EOS

      puppet_apply(pp)
    end

    it 'should find the user' do
      shell("mysql -NBe \"SHOW GRANTS FOR test@tester\"") do |r|
        r.stdout.should =~ /GRANT ALL PRIVILEGES ON `test`.* TO 'test'@'tester' WITH GRANT OPTION/
        r.stderr.should be_empty
        r.exit_code.should be_zero
      end
    end
  end

end
