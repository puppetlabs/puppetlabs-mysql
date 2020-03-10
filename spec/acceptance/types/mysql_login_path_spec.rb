require 'spec_helper_acceptance'

describe 'mysql_login_path' do
  describe 'setup' do
    pp = <<-MANIFEST
      yumrepo { 'repo.mysql.com':
        descr    => 'repo.mysql.com',
        baseurl  => 'http://repo.mysql.com/yum/mysql-5.6-community/el/#{host_inventory['facter']['os']['release']['major']}/$basearch/',
        gpgkey   => 'http://repo.mysql.com/RPM-GPG-KEY-mysql',
        enabled  => 1,
        gpgcheck => 1,
      }

      class {'::mysql::client':
        package_name => 'mysql-community-client',
      }

    MANIFEST
    it 'works with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'create login path with socket' do
    describe 'create login path' do
      pp = <<-MANIFEST
        mysql_login_path { 'local_socket':
          ensure => present,
        }

      MANIFEST
    end


  end
  # mysql_config_editor set --login-path=mysql1  --host=localhost \
  #   --port=3306 --socket=/path/to/socket --user=root --password
  #login-path                        client
  #host                              FALSE
  #password                          FALSE
  #user                              FALSE
  #warn                              TRUE
  #socket                            FALSE
  #port                              FALSE
end