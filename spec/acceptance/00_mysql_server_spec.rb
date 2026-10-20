# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'mysql class' do
  describe 'advanced config' do
    let(:pp) do
      <<-MANIFEST
        class { 'mysql::server':
          manage_config_file      => 'true',
          override_options        => { 'mysqld' => { 'key_buffer_size' => '32M' }},
          package_ensure          => 'present',
          purge_conf_dir          => 'true',
          remove_default_accounts => 'true',
          restart                 => 'true',
          root_group              => 'root',
          root_password           => 'test',
          service_enabled         => 'true',
          service_manage          => 'true',
          users                   => {
            'someuser@localhost' => {
              ensure                   => 'present',
              max_connections_per_hour => '0',
              max_queries_per_hour     => '0',
              max_updates_per_hour     => '0',
              max_user_connections     => '0',
              password_hash            => '*F3A2A51A9B0F2BE2468926B4132313728C250DBF',
            }},
          grants                  => {
            'someuser@localhost/somedb.*' => {
              ensure     => 'present',
              options    => ['GRANT'],
              privileges => ['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
              table      => 'somedb.*',
              user       => 'someuser@localhost',
            },
          },
          databases => {
            'somedb' => {
              ensure  => 'present',
              charset => '#{charset}',
              collate => '#{charset}_general_ci',
            },
          }
        }
      MANIFEST
    end

    it 'behaves idempotently' do
      idempotent_apply(pp)
    end

    describe 'override_options' do
      let(:pp) do
        <<-MANIFEST
        class { '::mysql::server':
        override_options => {
                  'mysqld' => {
                  'log-bin' => '/var/log/mariadb/mariadb-bin.log',}
           }
          }
        MANIFEST
      end

      it 'can be set' do
        # TODO : Returning warning message while running above manifest
        # Warning: Facter: Container runtime, 'docker', is unsupported, setting to, 'container_other'
        apply_manifest(pp)
      end
    end
  end

  describe 'syslog configuration' do
    let(:pp) do
      <<-MANIFEST
        class { 'mysql::server':
          override_options => { 'mysqld' => { 'log-error' => undef }, 'mysqld_safe' => { 'log-error' => false, 'syslog' => true }},
        }
      MANIFEST
    end

    it 'behaves idempotently' do
      idempotent_apply(pp)
    end
  end

  describe 'prefetch with managed subset' do
    let(:bootstrap_pp) do
      <<-MANIFEST
        class { 'mysql::server':
          root_password   => 'test',
          service_enabled => 'true',
          service_manage  => 'true',
        }
      MANIFEST
    end

    let(:subset_pp) do
      <<-MANIFEST
        class { 'mysql::server':
          root_password   => 'test',
          service_enabled => 'true',
          service_manage  => 'true',
        }

        mysql_database { 'managed_db':
          ensure  => 'present',
          charset => '#{charset}',
          collate => '#{charset}_general_ci',
        }

        mysql_user { 'managed_user@localhost':
          ensure => 'present',
        }

        mysql_grant { 'managed_user@localhost/managed_db.*':
          ensure     => 'present',
          privileges => ['SELECT'],
          table      => 'managed_db.*',
          user       => 'managed_user@localhost',
          require    => [Mysql_user['managed_user@localhost'], Mysql_database['managed_db']],
        }
      MANIFEST
    end

    let(:fixtures_pp) do
      <<-MANIFEST
        class { 'mysql::server':
          root_password   => 'test',
          service_enabled => 'true',
          service_manage  => 'true',
        }

        mysql_database { 'unmanaged_db':
          ensure  => 'present',
          charset => '#{charset}',
          collate => '#{charset}_general_ci',
        }

        mysql_user { 'managed_user@localhost':
          ensure => 'present',
        }

        mysql_user { 'unmanaged_user@localhost':
          ensure => 'present',
        }

        mysql_grant { 'managed_user@localhost/unmanaged_db.*':
          ensure     => 'present',
          privileges => ['INSERT'],
          table      => 'unmanaged_db.*',
          user       => 'managed_user@localhost',
          require    => [Mysql_user['managed_user@localhost'], Mysql_database['unmanaged_db']],
        }

        mysql_grant { 'unmanaged_user@localhost/unmanaged_db.*':
          ensure     => 'present',
          privileges => ['SELECT'],
          table      => 'unmanaged_db.*',
          user       => 'unmanaged_user@localhost',
          require    => [Mysql_user['unmanaged_user@localhost'], Mysql_database['unmanaged_db']],
        }
      MANIFEST
    end

    it 'applies server setup' do
      idempotent_apply(bootstrap_pp)
    end

    it 'creates managed and unmanaged fixture resources' do
      apply_manifest(fixtures_pp, catch_failures: true)
    end

    it 'manages only the declared subset idempotently' do
      idempotent_apply(subset_pp)
    end

    it 'keeps unmanaged resources present' do
      probe = run_shell('command -v mysql || command -v mariadb', expect_failures: true)
      db_client = probe.stdout.to_s.strip
      skip('No mysql/mariadb client available on acceptance target') if db_client.empty?

      db_query = "SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='unmanaged_db'"
      db_result = run_shell("#{db_client} -NBe \"#{db_query}\"")
      expect(db_result.exit_code).to eq 0
      expect(db_result.stdout).to match(%r{^unmanaged_db$})

      user_query = "SELECT CONCAT(user, '@', host) FROM mysql.user WHERE CONCAT(user, '@', host)='unmanaged_user@localhost'"
      user_result = run_shell("#{db_client} -NBe \"#{user_query}\"")
      expect(user_result.exit_code).to eq 0
      expect(user_result.stdout).to match(%r{^unmanaged_user@localhost$})
    end
  end
end
