require 'spec_helper_acceptance'

describe 'mysql_plugin' do
  describe 'setup' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'mysql::server': }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
  end

  describe 'load plugin' do
    it 'should work without errors' do
      pp = <<-EOS
        mysql_plugin { 'auth_socket':
          ensure => present,
          soname => 'auth_socket.so',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    it 'should find the plugin' do
      shell("mysql -NBe \"select plugin_name from information_schema.plugins where plugin_name='auth_socket'\"") do |r|
        expect(r.stdout).to match(/^auth_socket$/)
        expect(r.stderr).to be_empty
      end
    end
  end

end
