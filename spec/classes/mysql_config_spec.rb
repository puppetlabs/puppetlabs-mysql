require 'spec_helper'
describe 'mysql::config' do

  let :constant_parameter_defaults do
    {
     :root_password     => 'UNSET',
     :old_root_password => '',
     :bind_address      => '127.0.0.1',
     :port              => '3306',
     :etc_root_password => false,
     :datadir           => '/var/lib/mysql',
     :ssl               => false,
     :ssl_ca            => '/etc/mysql/cacert.pem',
     :ssl_cert          => '/etc/mysql/server-cert.pem',
     :ssl_key           => '/etc/mysql/server-key.pem'
    }
  end

  describe 'with osfamily specific defaults' do
    {
      'Debian' => {
         :service_name => 'mysql',
         :config_file  => '/etc/mysql/my.cnf',
         :socket       => '/var/run/mysqld/mysqld.sock'
      },
      'Redhat' => {
         :service_name => 'mysqld',
         :config_file  => '/etc/my.cnf',
         :socket       => '/var/lib/mysql/mysql.sock'
      }
    }.each do |osfamily, osparams|


      describe "when osfamily is #{osfamily}" do

        let :facts do
          {:osfamily => osfamily}
        end

        describe 'when root password is set' do

          let :params do
           {:root_password => 'foo'}
          end

          it { should contain_exec('set_mysql_rootpw').with(
            'command'   => 'mysqladmin -u root  password foo',
            'logoutput' => true,
            'unless'    => "mysqladmin -u root -pfoo status > /dev/null",
            'path'      => '/usr/local/sbin:/usr/bin'
          )}

          it { should contain_file('/root/.my.cnf').with(
            'content' => "[client]\nuser=root\nhost=localhost\npassword=foo\n",
            'require' => 'Exec[set_mysql_rootpw]'
          )}

        end

        describe 'when root password and old password are set' do
          let :params do
           {:root_password => 'foo', :old_root_password => 'bar'}
          end

          it { should contain_exec('set_mysql_rootpw').with(
            'command'   => 'mysqladmin -u root -pbar password foo',
            'logoutput' => true,
            'unless'    => "mysqladmin -u root -pfoo status > /dev/null",
            'path'      => '/usr/local/sbin:/usr/bin'
          )}

        end

        [
          {},
          {
            :service_name => 'dans_service',
            :config_file  => '/home/dan/mysql.conf',
            :service_name => 'dans_mysql',
            :socket       => '/home/dan/mysql.sock',
            :bind_address => '0.0.0.0',
            :port         => '3306',
            :datadir      => '/path/to/datadir',
            :ssl          => true,
            :ssl_ca       => '/path/to/cacert.pem',
            :ssl_cert     => '/path/to/server-cert.pem',
            :ssl_key      => '/path/to/server-key.pem'
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

            it { should contain_exec('mysqld-restart').with(
              :refreshonly => true,
              :path        => '/sbin/:/usr/sbin/:/usr/bin/:/bin/',
              :command     => "service #{param_values[:service_name]} restart"
            )}

            it { should_not contain_exec('set_mysql_rootpw') }

            it { should_not contain_file('/root/.my.cnf')}

            it { should contain_file('/etc/mysql').with(
              'owner'  => 'root',
              'group'  => 'root',
              'notify' => 'Exec[mysqld-restart]',
              'ensure' => 'directory',
              'mode'   => '0755'
            )}
            it { should contain_file('/etc/mysql/conf.d').with(
              'owner'  => 'root',
              'group'  => 'root',
              'notify' => 'Exec[mysqld-restart]',
              'ensure' => 'directory',
              'mode'   => '0755'
            )}
            it { should contain_file(param_values[:config_file]).with(
              'owner'  => 'root',
              'group'  => 'root',
              'notify' => 'Exec[mysqld-restart]',
              'mode'   => '0644'
            )}
            it 'should have a template with the correct contents' do
              content = param_value(subject, 'file', param_values[:config_file], 'content')
              expected_lines = [
                "port    = #{param_values[:port]}",
                "socket    = #{param_values[:socket]}",
                "datadir   = #{param_values[:datadir]}",
                "bind-address    = #{param_values[:bind_address]}"
              ]
              if param_values[:ssl]
                expected_lines = expected_lines |
                  [
                    "ssl-ca    = #{param_values[:ssl_ca]}",
                    "ssl-cert  = #{param_values[:ssl_cert]}",
                    "ssl-key   = #{param_values[:ssl_key]}"
                  ]
              end
              (content.split("\n") & expected_lines).should == expected_lines
            end
          end
        end
      end
    end
  end

  describe 'when etc_root_password is set with password' do

    let :facts do
      {:osfamily => 'Debian'}
    end

    let :params do
     {:root_password => 'foo', :old_root_password => 'bar', :etc_root_password => true}
    end

    it { should contain_exec('set_mysql_rootpw').with(
      'command'   => 'mysqladmin -u root -pbar password foo',
      'logoutput' => true,
      'unless'    => "mysqladmin -u root -pfoo status > /dev/null",
      'path'      => '/usr/local/sbin:/usr/bin'
    )}

    it { should contain_file('/root/.my.cnf').with(
      'content' => "[client]\nuser=root\nhost=localhost\npassword=foo\n",
      'require' => 'Exec[set_mysql_rootpw]'
    )}

  end

  describe 'setting etc_root_password should fail on redhat' do
    let :facts do
      {:osfamily => 'Redhat'}
    end

    let :params do
     {:root_password => 'foo', :old_root_password => 'bar', :etc_root_password => true}
    end

    it 'should fail' do
      expect do
        subject
      end.should raise_error(Puppet::Error, /Duplicate (declaration|definition)/)
    end

  end

end
