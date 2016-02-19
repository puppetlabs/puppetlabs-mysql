require 'spec_helper_acceptance'

describe 'mysql::user define' do
  describe 'creating a user' do
    let(:pp) do
      <<-EOS
        class { 'mysql::server': root_password => 'password' }
        mysql::db { 'spec1':
          user     => 'root1',
          password => 'password',
        }
        mysql::user { 'user1':
          password       => 'password',
          dbname         => 'spec1',
        }
      EOS
    end
    it_behaves_like "a idempotent resource"

    describe command("mysql -e 'select host, user, password from mysql.user;'") do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match /^spec1$/ }
    end
  end

  describe 'creating a user with user parameter' do
    let(:check_command) { " | grep realuser" }
    let(:pp) do
      <<-EOS
        class { 'mysql::server': override_options => { 'root_password' => 'password' } }
        mysql::db { 'spec1':
          user     => 'root1',
          password => 'password',
        }
        mysql::user { 'user1':
          user     => 'realuser',
          password => 'password',
          dbname   => 'spec1',
        }
      EOS
    end
    it_behaves_like "a idempotent resource"

    describe command("mysql -e 'select host, user, password from mysql.user;'") do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match /^realuser$/ }
    end
  end
end
