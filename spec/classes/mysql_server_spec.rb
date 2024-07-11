# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::server' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with defaults' do
        it { is_expected.to contain_class('mysql::params') }
        it { is_expected.to contain_class('mysql::server::install') }
        it { is_expected.to contain_class('mysql::server::config') }
        it { is_expected.to contain_class('mysql::server::managed_dirs') }
        it { is_expected.to contain_class('mysql::server::installdb') }
        it { is_expected.to contain_class('mysql::server::service') }
        it { is_expected.to contain_class('mysql::server::root_password') }
        it { is_expected.to contain_class('mysql::server::providers') }
        it { is_expected.to contain_file('mysql-config-file').that_comes_before('Service[mysqld]') }
        it { is_expected.not_to contain_file('mysql-config-file').that_notifies('Service[mysqld]') }

        it { is_expected.to contain_anchor('mysql::server::start') }
        it { is_expected.to contain_anchor('mysql::server::end') }

        it {
          is_expected.to contain_exec('wait_for_mysql_socket_to_open')
            .with(
              command:   ['test', '-S', %r{.*\.sock}],
              unless:    [['test', '-S', %r{.*\.sock}]],
              tries:     '3',
              try_sleep: '10',
              require:   'Service[mysqld]',
              path:      '/bin:/usr/bin',
            )
        }
      end

      context 'with remove_default_accounts set' do
        let(:params) { { remove_default_accounts: true } }

        it { is_expected.to contain_class('mysql::server::account_security') }
      end

      context 'when not managing config file' do
        let(:params) { { manage_config_file: false } }

        it { is_expected.to compile.with_all_deps }
      end

      context 'when not managing the service' do
        let(:params) { { service_manage: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_service('mysqld') }
      end

      context 'configuration options' do
        context 'when specifying both $override_options and $options' do
          let(:params) do
            {
              override_options: { 'mysqld' => { 'datadir' => '/tmp' } },
              options: { 'mysqld' => { 'max_allowed_packet' => '12M' } }
            }
          end

          it { is_expected.to compile.and_raise_error(%r{You can't specify \$options and \$override_options simultaneously, see the README section 'Customize server options'!}) }
        end

        context 'when specifying $options' do
          let(:params) do
            {
              options: { 'mysqld' => { 'datadir' => '/tmp' } }
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_mysql_datadir('/tmp') }
          it { is_expected.not_to contain_mysql_bind_addr('127.0.0.1') }
        end
      end

      context 'mysql::server::install' do
        it 'contains the package by default' do
          is_expected.to contain_package('mysql-server').with(ensure: :present)
        end

        context 'with package_manage set to true' do
          let(:params) { { package_manage: true } }

          it { is_expected.to contain_package('mysql-server') }
        end

        context 'with package_manage set to false' do
          let(:params) { { package_manage: false } }

          it { is_expected.not_to contain_package('mysql-server') }
        end

        context 'with datadir overridden' do
          let(:params) { { override_options: { 'mysqld' => { 'datadir' => '/tmp' } } } }

          it { is_expected.to contain_mysql_datadir('/tmp') }
        end

        context 'with package provider' do
          let(:params) do
            {
              package_provider: 'dpkg',
              package_source: '/somewhere'
            }
          end

          it do
            is_expected.to contain_package('mysql-server').with(
              provider: 'dpkg',
              source: '/somewhere',
            )
          end
        end
      end

      context 'mysql::server::service' do
        context 'with defaults' do
          it { is_expected.to contain_service('mysqld') }
        end

        context 'with package_manage set to true' do
          let(:params) { { package_manage: true } }

          it { is_expected.to contain_service('mysqld').that_requires('Package[mysql-server]') }
        end

        context 'with package_manage set to false' do
          let(:params) { { package_manage: false } }

          it { is_expected.to contain_service('mysqld') }
          it { is_expected.not_to contain_service('mysqld').that_requires('Package[mysql-server]') }
        end

        context 'service_enabled set to false' do
          let(:params) { { service_enabled: false } }

          it do
            is_expected.to contain_service('mysqld').with(ensure: :stopped)
          end

          context 'with package_manage set to true' do
            let(:params) { { package_manage: true } }

            it { is_expected.to contain_package('mysql-server') }
          end

          context 'with package_manage set to false' do
            let(:params) { { package_manage: false } }

            it { is_expected.not_to contain_package('mysql-server') }
          end

          context 'with datadir overridden' do
            let(:params) { { override_options: { 'mysqld' => { 'datadir' => '/tmp' } } } }

            it { is_expected.to contain_mysql_datadir('/tmp') }
          end
        end

        context 'with log-error overridden' do
          let(:params) { { override_options: { 'mysqld' => { 'log-error' => '/tmp/error.log' } } } }

          it { is_expected.to contain_file('/tmp/error.log') }
        end

        context 'default bind-address' do
          it { is_expected.to contain_file('mysql-config-file').with_content(%r{^bind-address = 127.0.0.1}) }
        end

        context 'with defined bind-address' do
          let(:params) { { override_options: { 'mysqld' => { 'bind-address' => '1.1.1.1' } } } }

          it { is_expected.to contain_file('mysql-config-file').with_content(%r{^bind-address = 1.1.1.1}) }
        end

        context 'without bind-address' do
          let(:params) { { override_options: { 'mysqld' => { 'bind-address' => :undef } } } }

          it { is_expected.to contain_file('mysql-config-file').without_content(%r{^bind-address}) }
        end

        context 'with reload_on_config_change' do
          let(:params) { { 'reload_on_config_change' => true } }

          it { is_expected.to contain_file('mysql-config-file').that_notifies('Service[mysqld]') }
        end
      end

      context 'mysql::server::root_password' do
        describe 'when defaults' do
          it {
            is_expected.to contain_exec('remove install pass').with(
              command: <<-'CMD'.gsub(%r{^\s+}, ''),
                mysqladmin -u root --password=$(grep -o '[^ ]+$' /.mysql_secret) password && \
                (rm -f  /.mysql_secret; exit 0) || \
                (rm -f /.mysql_secret; exit 1)
                CMD
              onlyif: [['test', '-f', '/.mysql_secret']],
              path: '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
            )
          }

          it { is_expected.not_to contain_mysql_user('root@localhost') }
          it { is_expected.not_to contain_file('/root/.my.cnf') }
        end

        describe 'when root_password set' do
          let(:params) { { root_password: 'SET' } }

          it { is_expected.to contain_mysql_user('root@localhost') }

          it { is_expected.to contain_file('/root/.my.cnf').with(show_diff: false).that_requires('Mysql_user[root@localhost]') }
        end

        describe 'when root_password set, create_root_user set to false' do
          let(:params) { { root_password: 'SET', create_root_user: false } }

          it { is_expected.not_to contain_mysql_user('root@localhost') }

          it { is_expected.to contain_file('/root/.my.cnf').with(show_diff: false) }
        end

        describe 'when root_password set, create_root_my_cnf set to false' do
          let(:params) { { root_password: 'SET', create_root_my_cnf: false } }

          it { is_expected.to contain_mysql_user('root@localhost') }
          it { is_expected.not_to contain_file('/root/.my.cnf') }
        end

        describe 'when root_password set, create_root_user and create_root_my_cnf set to false' do
          let(:params) { { root_password: 'SET', create_root_user: false, create_root_my_cnf: false } }

          it { is_expected.not_to contain_mysql_user('root@localhost') }
          it { is_expected.not_to contain_file('/root/.my.cnf') }
        end
      end

      context 'mysql::server::providers' do
        describe 'with users' do
          let(:params) do
            { users: {
              'foo@localhost' => {
                'max_connections_per_hour' => '1',
                'max_queries_per_hour' => '2',
                'max_updates_per_hour' => '3',
                'max_user_connections' => '4',
                'password_hash' => '*F3A2A51A9B0F2BE2468926B4132313728C250DBF'
              },
              'foo2@localhost' => {}
            } }
          end

          it {
            is_expected.to contain_mysql_user('foo@localhost').with(
              max_connections_per_hour: '1', max_queries_per_hour: '2',
              max_updates_per_hour: '3', max_user_connections: '4',
              password_hash: '*F3A2A51A9B0F2BE2468926B4132313728C250DBF'
            )
          }

          it {
            is_expected.to contain_mysql_user('foo2@localhost').with(
              max_connections_per_hour: nil, max_queries_per_hour: nil,
              max_updates_per_hour: nil, max_user_connections: nil,
              password_hash: nil
            )
          }
        end

        describe 'with users and Sensitive password_hash' do
          let(:params) do
            { users: {
              'foo@localhost' => {
                'max_connections_per_hour' => '1',
                'max_queries_per_hour' => '2',
                'max_updates_per_hour' => '3',
                'max_user_connections' => '4',
                'password_hash' => sensitive('*F3A2A51A9B0F2BE2468926B4132313728C250DBF')
              },
              'foo2@localhost' => {}
            } }
          end

          it {
            is_expected.to contain_mysql_user('foo@localhost').with(
              max_connections_per_hour: '1', max_queries_per_hour: '2',
              max_updates_per_hour: '3', max_user_connections: '4',
              password_hash: 'Sensitive [value redacted]'
            )
          }
        end

        describe 'with grants' do
          let(:params) do
            { grants: {
              'foo@localhost/somedb.*' => {
                'user' => 'foo@localhost',
                'table' => 'somedb.*',
                'privileges' => ['SELECT', 'UPDATE'],
                'options' => ['GRANT']
              },
              'foo2@localhost/*.*' => {
                'user' => 'foo2@localhost',
                'table' => '*.*',
                'privileges' => ['SELECT']
              }
            } }
          end

          it {
            is_expected.to contain_mysql_grant('foo@localhost/somedb.*').with(
              user: 'foo@localhost', table: 'somedb.*',
              privileges: ['SELECT', 'UPDATE'], options: ['GRANT']
            )
          }

          it {
            is_expected.to contain_mysql_grant('foo2@localhost/*.*').with(
              user: 'foo2@localhost', table: '*.*',
              privileges: ['SELECT'], options: nil
            )
          }
        end

        describe 'with databases' do
          let(:params) do
            { databases: {
              'somedb' => {
                'charset' => 'latin1',
                'collate' => 'latin1'
              },
              'somedb2' => {}
            } }
          end

          it {
            is_expected.to contain_mysql_database('somedb').with(
              charset: 'latin1',
              collate: 'latin1',
            )
          }

          it { is_expected.to contain_mysql_database('somedb2') }
        end
      end
    end
  end
end
