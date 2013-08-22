require 'spec_helper'
describe 'mysql::config' do

  let :constant_parameter_defaults do
    {
     :root_password                   => 'UNSET',
     :old_root_password               => '',
     :max_connections                 => '151',
     :bind_address                    => '127.0.0.1',
     :port                            => '3306',
     :etc_root_password               => false,
     :datadir                         => '/var/lib/mysql',
     :default_engine                  => 'UNSET',
     :ssl                             => false,
     :key_buffer                      => '16M',
     :max_allowed_packet              => '16M',
     :thread_stack                    => '256K',
     :thread_cache_size               => 8,
     :myisam_recover                  => 'BACKUP',
     :query_cache_limit               => '1M',
     :query_cache_size                => '16M',
     :max_binlog_size                 => '100M',
     :expire_logs_days                => 10,
     :character_set                   => 'UNSET',
     :tmp_table_size                  => 'UNSET',
     :max_heap_table_size             => 'UNSET',
     :table_open_cache                => 'UNSET',
     :long_query_time                 => 'UNSET',
     :server_id                       => 'UNSET',
     :sql_log_bin                     => 'UNSET',
     :log_bin                         => 'UNSET',
     :binlog_do_db                    => 'UNSET',
     :log_bin_trust_function_creators => 'UNSET',
     :replicate_ignore_table          => 'UNSET',
     :replicate_wild_do_table         => 'UNSET',
     :replicate_wild_ignore_table     => 'UNSET',
     :ft_min_word_len                 => 'UNSET',
     :ft_max_word_len                 => 'UNSET'
    }
  end

  describe 'with osfamily specific defaults' do
    {
      'Debian' => {
         :datadir         => '/var/lib/mysql',
         :service_name    => 'mysql',
         :config_file     => '/etc/mysql/my.cnf',
         :socket          => '/var/run/mysqld/mysqld.sock',
         :pidfile         => '/var/run/mysqld/mysqld.pid',
         :root_group      => 'root',
         :ssl_ca          => '/etc/mysql/cacert.pem',
         :ssl_cert        => '/etc/mysql/server-cert.pem',
         :ssl_key         => '/etc/mysql/server-key.pem'
      },
      'FreeBSD' => {
         :datadir         => '/var/db/mysql',
         :service_name    => 'mysql-server',
         :config_file     => '/var/db/mysql/my.cnf',
         :socket          => '/tmp/mysql.sock',
         :pidfile         => '/var/db/mysql/mysql.pid',
         :root_group      => 'wheel'
      },
      'RedHat' => {
         :datadir         => '/var/lib/mysql',
         :service_name    => 'mysqld',
         :config_file     => '/etc/my.cnf',
         :socket          => '/var/lib/mysql/mysql.sock',
         :pidfile         => '/var/run/mysqld/mysqld.pid',
         :root_group      => 'root',
         :ssl_ca          => '/etc/mysql/cacert.pem',
         :ssl_cert        => '/etc/mysql/server-cert.pem',
         :ssl_key         => '/etc/mysql/server-key.pem'
      }
    }.each do |osfamily, osparams|


      describe "when osfamily is #{osfamily}" do

        let :facts do
          {:osfamily => osfamily, :root_home => '/root'}
        end

        describe 'when root password is set' do

          let :params do
           {:root_password => 'foo'}
          end

          it { should contain_exec('set_mysql_rootpw').with(
            'command'   => 'mysqladmin -u root  password \'foo\'',
            'logoutput' => true,
            'unless'    => "mysqladmin -u root -p\'foo\' status > /dev/null",
            'path'      => '/usr/local/sbin:/usr/bin:/usr/local/bin'
          )}

          it { should contain_file('/root/.my.cnf').with(
            'content' => "[client]\nuser=root\nhost=localhost\npassword='foo'\nsocket=#{osparams[:socket]}",
            'require' => 'Exec[set_mysql_rootpw]'
          )}

        end

        describe 'when root password and old password are set' do
          let :params do
           {:root_password => 'foo', :old_root_password => 'bar'}
          end

          it { should contain_exec('set_mysql_rootpw').with(
            'command'   => 'mysqladmin -u root -p\'bar\' password \'foo\'',
            'logoutput' => true,
            'unless'    => "mysqladmin -u root -p\'foo\' status > /dev/null",
            'path'      => '/usr/local/sbin:/usr/bin:/usr/local/bin'
          )}

        end

        [
          {},
          {
            :service_name         => 'dans_service',
            :config_file          => '/home/dan/mysql.conf',
            :pidfile              => '/home/dan/mysql.pid',
            :socket               => '/home/dan/mysql.sock',
            :bind_address         => '0.0.0.0',
            :port                 => '3306',
            :datadir              => '/path/to/datadir',
            :default_engine       => 'InnoDB',
            :ssl                  => true,
            :ssl_ca               => '/path/to/cacert.pem',
            :ssl_cert             => '/path/to/server-cert.pem',
            :ssl_key              => '/path/to/server-key.pem',
            :key_buffer           => '16M',
            :max_allowed_packet   => '32M',
            :thread_stack         => '256K',
            :query_cache_size     => '16M',
            :character_set        => 'utf8',
            :max_connections      => 1000,
            :tmp_table_size       => '4096M',
            :max_heap_table_size  => '4096M',
            :table_open_cache     => 2048,
            :long_query_time      => 0.5,
            :ft_min_word_len      => 3,
            :ft_max_word_len      => 10
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

            it { should contain_file('/root/.my.cnf')}
          end
        end
      end
    end
  end

  describe 'when etc_root_password is set with password' do

    let :facts do
      {:osfamily => 'Debian', :root_home => '/root'}
    end

    let :params do
     {
       :root_password => 'foo',
       :old_root_password => 'bar',
       :etc_root_password => true,
       :socket => '/tmp/mysql.sock',
    }
    end

    it { should contain_exec('set_mysql_rootpw').with(
      'command'   => 'mysqladmin -u root -p\'bar\' password \'foo\'',
      'logoutput' => true,
      'unless'    => "mysqladmin -u root -p\'foo\' status > /dev/null",
      'path'      => '/usr/local/sbin:/usr/bin:/usr/local/bin'
    )}

    it { should contain_file('/root/.my.cnf').with(
      'content' => "[client]\nuser=root\nhost=localhost\npassword='foo'\nsocket=#{params[:socket]}",
      'require' => 'Exec[set_mysql_rootpw]'
    )}

  end

end
