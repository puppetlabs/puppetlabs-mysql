require 'spec_helper'
describe 'mysql::server' do

  let :constant_parameter_defaults do
    {:config_hash    => {},
     :package_ensure => 'present',
     :enabled        => true
    }
  end

  describe 'when ubuntu use upstart' do
    let :facts do
      { :osfamily => 'Debian',
        :operatingsystem => 'Ubuntu',
      }
    end

    it { should contain_service('mysqld').with(
      :name     => 'mysql',
      :ensure   => 'running',
      :enable   => 'true',
      :provider => 'upstart',
      :require  => 'Package[mysql-server]'
    )}
  end

  describe 'with osfamily specific defaults' do
    {
      'Debian' => {
        :service_name => 'mysql',
        :package_name => 'mysql-server'
      },
      'FreeBSD' => {
        :service_name => 'mysql-server',
        :package_name => 'databases/mysql55-server'
      },
      'Redhat' => {
        :service_name => 'mysqld',
        :package_name => 'mysql-server'
      }
    }.each do |osfamily, osparams|

      describe "when osfamily is #{osfamily}" do

        let :facts do
          { :osfamily => osfamily }
        end

        [
          {},
          {
            :package_name   => 'dans_package',
            :package_ensure => 'latest',
            :service_name   => 'dans_service',
            :config_hash    => {'root_password' => 'foo'},
            :enabled        => false
          }
        ].each do |passed_params|

          describe "with #{passed_params == {} ? 'default' : 'specified'} parameters" do

            let :parameter_defaults do
              constant_parameter_defaults.merge(osparams)
            end

            let :params do
              passed_params
            end

            let :param_values do
              parameter_defaults.merge(params)
            end

            it { should contain_package('mysql-server').with(
              :name   => param_values[:package_name],
              :ensure => param_values[:package_ensure]
            )}

            it { should contain_service('mysqld').with(
              :name    => param_values[:service_name],
              :ensure  => param_values[:enabled] ? 'running' : 'stopped',
              :enable  => param_values[:enabled],
              :require => 'Package[mysql-server]'
            )}

            it { should contain_service('mysqld').without_provider }
          end
        end
      end
    end
  end
end
