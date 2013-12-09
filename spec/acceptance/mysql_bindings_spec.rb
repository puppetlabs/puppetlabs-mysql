require 'spec_helper_acceptance'

describe 'mysql::bindings class' do
  osfamily = fact('osfamily')
  operatingsystem = fact('operatingsystem')

  case osfamily
  when 'RedHat'
    java_package   = 'mysql-connector-java'
    perl_package   = 'perl-DBD-MySQL'
    python_package = 'MySQL-python'
    ruby_package   = 'ruby-mysql'
  when 'Suse'
    java_package   = 'mysql-connector-java'
    perl_package   = 'perl-DBD-MySQL'
    python_package = 'python-mysql'
    case operatingsystem
    when /OpenSuSE/
      ruby_package = 'rubygem-mysql'
    when /(SLES|SLED)/
      ruby_package = 'ruby-mysql'
    end
  when 'Debian'
    java_package = 'libmysql-java'
    perl_package   = 'libdbd-mysql-perl'
    python_package = 'python-mysqldb'
    ruby_package   = 'libmysql-ruby'
  when 'FreeBSD'
    java_package = 'databases/mysql-connector-java'
    perl_package   = 'p5-DBD-mysql'
    python_package = 'databases/py-MySQLdb'
    ruby_package   = 'ruby-mysql'
  else
    case operatingsystem
    when 'Amazon'
      java_package = 'mysql-connector-java'
    perl_package   = 'perl-DBD-MySQL'
    python_package = 'MySQL-python'
    ruby_package   = 'ruby-mysql'
    end
  end

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'mysql::bindings': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end

  describe 'enabling bindings' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'mysql::bindings':
          java_enable   => true,
          perl_enable   => true,
          python_enable => true,
          ruby_enable   => true,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package(java_package) do
      it { should be_installed }
    end

    describe package(perl_package) do
      it { should be_installed }
    end

    describe package(python_package) do
      it { should be_installed }
    end

    describe package(ruby_package) do
      it { should be_installed }
    end
  end
end
