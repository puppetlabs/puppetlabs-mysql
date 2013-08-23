require 'spec_helper'
describe 'mysql::server::service' do

  describe 'when manage_config_file is true' do
    let :params do
      {:enabled            => true,
       :manage_service     => true,
       :service_name       => 'mysqld',
       :manage_config_file => true,
       :config_file        => '/etc/my.cnf'
      }
    end

    it { should contain_service('mysqld').with(
      :name      => 'mysqld',
      :ensure    => 'running',
      :enable    => 'true',
      :require   => 'Package[mysql-server]',
      :subscribe => 'File[/etc/my.cnf]'
    )}
  end

  describe 'when manage_config_file is false' do
    let :params do
      {:enabled            => true,
       :manage_service     => true,
       :service_name       => 'mysqld',
       :manage_config_file => false,
       :config_file        => '/etc/my.cnf'
      }
    end

    it { should contain_service('mysqld').with(
      :name      => 'mysqld',
      :ensure    => 'running',
      :enable    => 'true',
      :require   => 'Package[mysql-server]',
      :subscribe => nil
    )}
  end
end
