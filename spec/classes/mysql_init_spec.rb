require 'spec_helper'

describe 'mysql' do

  describe 'on a debian based os' do
    let :facts do
      { :osfamily => 'Debian'}
    end
    it { should contain_package('mysql_client').with(
      :name   => 'mysql-client',
      :ensure => 'present'
    )}
  end

  describe 'on a freebsd based os' do
    let :facts do
      { :osfamily => 'FreeBSD'}
    end
    it { should contain_package('mysql_client').with(
      :name   => 'databases/mysql55-client',
      :ensure => 'present'
    )}
  end

  describe 'on a redhat based os' do
    let :facts do
      {:osfamily => 'Redhat'}
    end
    it { should contain_package('mysql_client').with(
      :name   => 'mysql',
      :ensure => 'present'
    )}
    describe 'when parameters are supplied' do
      let :params do
        {:package_ensure => 'latest', :package_name => 'mysql_client'}
      end
      it { should contain_package('mysql_client').with(
        :name   => 'mysql_client',
        :ensure => 'latest'
      )}
    end
  end

  describe 'on any other os' do
    let :facts do
      {:osfamily => 'foo'}
    end

    it 'should fail' do
      expect do
        subject
      end.should raise_error(/Unsupported osfamily: foo/)
    end
  end

end
