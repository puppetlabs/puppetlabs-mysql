# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'mysql server class', if: ((os[:family] == 'debian' && os[:release].to_i > 8) || (os[:family] == 'redhat' && os[:release].to_i > 6)) do
  describe 'mariadb' do
    let(:pp) do
      <<-MANIFEST
        $osname = $facts['os']['name'].downcase
        yumrepo {'mariadb':
          baseurl  => "http://yum.mariadb.org/10.4/$osname${facts['os']['release']['major']}-aarch64/",
          gpgkey => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
          descr    => "MariaDB 10.4",
          enabled  => 1,
          gpgcheck => 0,
        }->
        class { '::mysql::server':
          require                => Yumrepo['mariadb'],
          package_name            => 'mariadb-server',
          service_name            => 'mariadb',
          root_password           => 'strongpassword',
          remove_default_accounts => true,
          managed_dirs            => ['/var/log','/var/run/mysql'],
          override_options        => {
            mysqld => {
              log-error =>  '/var/log/mariadb.log',
              pid-file =>  '/var/run/mysql/mysqld.pid',
            },
            mysqld_safe =>  {
              log-error =>  '/var/log/mariadb.log',
            },
          },
        }
      MANIFEST
    end

    it 'apply manifest' do
      apply_manifest(pp)
    end
    it 'mariadb connection' do
      result = run_shell('mysql --user="root" --password="strongpassword" -e "status"')
      expect(result.stdout).to match(%r{MariaDB})
      expect(result.stderr).to be_empty
    end
  end
end
