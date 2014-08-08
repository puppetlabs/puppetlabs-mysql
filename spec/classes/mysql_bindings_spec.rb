require 'spec_helper'

describe 'mysql::bindings' do
  let(:params) {{
    'java_enable'   => true,
    'perl_enable'   => true,
    'php_enable'    => true,
    'python_enable' => true,
    'ruby_enable'   => true,
    'client_dev'    => true,
    'daemon_dev'    => true,
  }}

  shared_examples 'bindings' do |osfamily, operatingsystem, operatingsystemrelease, java_name, perl_name, php_name, python_name, ruby_name, client_dev_name, daemon_dev_name|
    let :facts do
      { :osfamily => osfamily, :operatingsystem => operatingsystem,
        :operatingsystemrelease => operatingsystemrelease, :root_home => '/root',
      }
    end
    it { should contain_package('mysql-connector-java').with(
      :name   => java_name,
      :ensure => 'present'
    )}
    it { should contain_package('perl_mysql').with(
      :name     => perl_name,
      :ensure   => 'present'
    )}
    it { should contain_package('python-mysqldb').with(
      :name   => python_name,
      :ensure => 'present'
    )}
    it { should contain_package('ruby_mysql').with(
      :name     => ruby_name,
      :ensure   => 'present'
    )}
    if client_dev_name
      it { should contain_package('mysql-client_dev').with(
        :name     => client_dev_name,
        :ensure   => 'present'
      )}
    end
    if daemon_dev_name
      it { should contain_package('mysql-daemon_dev').with(
        :name     => daemon_dev_name,
        :ensure   => 'present'
      )}
    end
  end

  context 'Debian' do
    it_behaves_like 'bindings', 'Debian', 'Debian', '7.4','libmysql-java', 'libdbd-mysql-perl', 'php5-mysql', 'python-mysqldb', 'libmysql-ruby', 'libmysqlclient-dev', 'libmysqld-dev'
    it_behaves_like 'bindings', 'Debian', 'Ubuntu', '14.04', 'libmysql-java', 'libdbd-mysql-perl', 'php5-mysql', 'python-mysqldb', 'libmysql-ruby', 'libmysqlclient-dev', 'libmysqld-dev'
  end

  context 'freebsd' do
    it_behaves_like 'bindings', 'FreeBSD', 'FreeBSD', '10.0', 'databases/mysql-connector-java', 'p5-DBD-mysql', 'databases/php5-mysql', 'databases/py-MySQLdb', 'databases/ruby-mysql'
  end

  context 'redhat' do
    it_behaves_like 'bindings', 'RedHat', 'RedHat', '6.5', 'mysql-connector-java', 'perl-DBD-MySQL', 'php-mysql', 'MySQL-python', 'ruby-mysql', nil, 'mysql-devel'
    it_behaves_like 'bindings', 'RedHat', 'OpenSuSE', '11.3', 'mysql-connector-java', 'perl-DBD-MySQL', 'php-mysql', 'MySQL-python', 'ruby-mysql', nil, 'mysql-devel'
  end

  describe 'on any other os' do
    let :facts do
      {:osfamily => 'foo', :root_home => '/root'}
    end

    it 'should fail' do
      expect { subject }.to raise_error(/Unsupported platform:/)
    end
  end

end
