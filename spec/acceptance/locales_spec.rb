require 'spec_helper_acceptance'
require 'beaker/i18n_helper'

describe 'mysql localization', if: fact('osfamily') == 'Debian' do
  before :all do
    hosts.each do |host|
      on(host, "sed -i \"96i FastGettext.locale='ja'\" /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet.rb")
      change_locale_on(host, 'ja_JP')
    end
  end

  context 'when triggering puppet string warning' do
    let(:pp) do
      <<-EOS
    class { 'mysql::server':
            config_file             => '/tmp/mysql.sFlJdV/my.cnf',
            includedir              => '/tmp/mysql.sFlJdV/include',
            manage_config_file      => 'true',
            override_options        => { 'mysqld' => { 'key_buffer_size' => '32M' }},
            package_ensure          => 'present',
            purge_conf_dir          => 'true',
            remove_default_accounts => 'true',
            restart                 => 'true',
            root_group              => 'root',
            root_password           => 'test',
            old_root_password       => 'kittensnmittens',
            service_enabled         => 'false'
          }
      EOS
    end

    it 'displays Japanese error' do
      apply_manifest(pp, catch_error: true) do |r|
        expect(r.stderr).to match(%r{`old_root_password`属性は廃止予定であり、今後のリリースで廃止されます。}i)
      end
    end
  end

  context 'when triggering ruby simple string warning' do
    let(:pp) do
      <<-EOS
      mysql::db { 'mydb':
        user     => 'thisisalongusernametestfortoday',
        password => 'mypass',
        host     => 'localhost',
        grant    => ['SELECT', 'UPDATE'],
      }
    EOS
    end

    it 'displays Japanese error' do
      apply_manifest(pp, expect_failures: true) do |r|
        expect(r.stderr).to match(%r{MySQLユーザ名は最大16文字に制限されています。}i)
      end
    end
  end

  context 'when triggering ruby interpolated string warning' do
    let(:pp) do
      <<-EOS
      $password_hash = mysql_password('new_password', 'should not have second parameter')
    EOS
    end

    it 'displays Japanese error' do
      pending 'waiting on japanese translation in the po file'
      apply_manifest(pp, catch_error: true) do |r|
        expect(r.stderr).not_to match(%r{mysql_password(): Wrong number of arguments given (2 for 1)}i)
      end
    end
  end

  after :all do
    hosts.each do |host|
      on(host, 'sed -i "96d" /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet.rb')
      change_locale_on(host, 'en_US')
    end
  end
end
