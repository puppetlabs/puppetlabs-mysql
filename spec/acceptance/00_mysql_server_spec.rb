# frozen_string_literal: true

require 'spec_helper_acceptance'

# The export_locales method conflicts with our testing when the target system uses MariaDB, therefore it is being disabled for those systems.
# if os[:family] != 'debian' && os[:family] != 'ubuntu'
# export_locales
# end

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
              charset => #{fetch_charset},
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
        apply_manifest(pp, catch_failures: true) do |r|
          if (os[:family] == 'debian' && os[:release].to_i > 9) && Gem::Version.new(`puppet --version`) < Gem::Version.new('7.0')
            expect(r.stderr).to match(%r{locale environment variables were bad; continuing with LANG=C LC_ALL=C})
          else
            expect(r.stderr).to be_empty
          end
        end
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
end
