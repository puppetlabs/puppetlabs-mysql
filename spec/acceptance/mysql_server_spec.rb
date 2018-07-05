require 'spec_helper_acceptance'
require 'pry-byebug'

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
              charset => 'utf8',
            },
          }
        }
      MANIFEST
    end

    it_behaves_like 'a idempotent resource'
  end

  # describe 'minimal config' do
  #   before(:all) do
  #     @tmpdir = default.tmpdir('mysql')
  #   end
  #   # 'manage_config_file' being set to false can cause random failures in Debian 9
  #   let(:manage_config_file) do
  #     if fact('operatingsystem') == 'Debian' && fact('operatingsystemrelease') == '9'
  #       'true'
  #     else
  #       'false'
  #     end
  #   end
  #   let(:pp) do
  #     <<-MANIFEST
  #       class { 'mysql::server':
  #         manage_config_file      => '#{manage_config_file}',
  #         override_options        => { 'mysqld' => { 'key_buffer_size' => '32M' }},
  #         package_ensure          => 'present',
  #         purge_conf_dir          => 'false',
  #         remove_default_accounts => 'false',
  #         restart                 => 'false',
  #         root_group              => 'root',
  #         root_password           => 'test',
  #         service_enabled         => 'false',
  #         service_manage          => 'false',
  #         users                   => {},
  #         grants                  => {},
  #         databases               => {},
  #       }
  #     MANIFEST
  #   end

  #   it_behaves_like 'a idempotent resource'
  # end

  describe 'syslog configuration' do
    let(:pp) do
      <<-MANIFEST
        class { 'mysql::server':
          override_options => { 'mysqld' => { 'log-error' => undef }, 'mysqld_safe' => { 'log-error' => false, 'syslog' => true }},
        }
      MANIFEST
    end

    # TODO: This test causes mariadb to crash on Debian 9
    it_behaves_like 'a idempotent resource'
  end

  context 'when changing the password' do
    let(:password) { 'THE NEW SECRET' }
    let(:pp) { "class { 'mysql::server': root_password => '#{password}' }" }

    it 'does not display the password' do
      result = apply_manifest(pp, catch_failures: true)
      # this does not actually prove anything, as show_diff in the puppet config defaults to false.
      expect(result.stdout).not_to match %r{#{password}}
    end

    it_behaves_like 'a idempotent resource'
  end
end
