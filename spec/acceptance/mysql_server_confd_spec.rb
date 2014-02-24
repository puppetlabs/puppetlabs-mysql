require 'spec_helper_acceptance'

describe 'mysql::server::confd' do
  let(:mysql_server_pp) { <<-EOS
    class { 'mysql::server':
      restart          => true,
      purge_conf_dir   => true,
      override_options => {
        'mysqld' => {
          'server_id' => '123',
        },
      },
    }
    EOS
  }

  it 'should setup mysql::server with no errors' do
    apply_manifest(mysql_server_pp, :catch_failures => true)
  end

  it 'should find server_id set by mysql::server' do
    shell("mysql -NBe \"SHOW VARIABLES LIKE 'server_id'\"") do |r|
      expect(r.stdout).to match(/^server_id\t123$/)
      expect(r.stderr).to be_empty
    end
  end

  it 'should apply mysql::server::confd with no errors' do
    pp = <<-EOS
#{mysql_server_pp}
      mysql::server::confd { 'server_id':
        content => "[mysqld]\nserver_id = 456\n",
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  it 'should find server_id set by mysql::server::confd' do
    shell("mysql -NBe \"SHOW VARIABLES LIKE 'server_id'\"") do |r|
      expect(r.stdout).to match(/^server_id\t456$/)
      expect(r.stderr).to be_empty
    end
  end
end
