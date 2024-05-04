# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::server::account_security' do
  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }
    context "on #{os}" do
      let(:pre_condition) do
        <<-MANIFEST
        anchor {'mysql::server::end': }
        MANIFEST
      end

      context 'with fqdn==myhost.mydomain' do
        let(:facts) do
          override_facts(
            super(),
            'root_home' => '/root',
            'networking' => {
              'fqdn' => 'myhost.mydomain',
              'hostname' => 'myhost',
            },
          )
        end

        ['root@localhost.localdomain',
         '@localhost.localdomain',
         'root@myhost.mydomain',
         'root@127.0.0.1',
         'root@::1',
         '@myhost.mydomain',
         '@localhost',
         '@%'].each do |user|
          it "removes Mysql_User[#{user}]" do # rubocop:disable RSpec/RepeatedExample,RSpec/RepeatedDescription
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end

        # When the hostname doesn't match the fqdn we also remove these.
        # We don't need to test the inverse as when they match they are
        # covered by the above list.
        ['root@myhost', '@myhost'].each do |user|
          it "removes Mysql_User[#{user}]" do # rubocop:disable RSpec/RepeatedExample,RSpec/RepeatedDescription
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end

        it 'removes Mysql_database[test]' do
          is_expected.to contain_mysql_database('test').with_ensure('absent')
        end
      end

      context 'with fqdn==localhost' do
        let(:facts) do
          override_facts(
            super(),
            'root_home' => '/root',
            'networking' => {
              'fqdn' => 'localhost',
              'hostname' => 'localhost',
            },
          )
        end

        ['root@127.0.0.1',
         'root@::1',
         '@localhost',
         'root@localhost.localdomain',
         '@localhost.localdomain',
         '@%'].each do |user|
          it "removes Mysql_User[#{user}] for fqdn==localhost" do
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end
      end

      context 'with fqdn==localhost.localdomain' do
        let(:facts) do
          override_facts(
            super(),
            'root_home' => '/root',
            'networking' => {
              'fqdn' => 'localhost.localdomain',
              'hostname' => 'localhost',
            },
          )
        end

        ['root@127.0.0.1',
         'root@::1',
         '@localhost',
         'root@localhost.localdomain',
         '@localhost.localdomain',
         '@%'].each do |user|
          it "removes Mysql_User[#{user}] for fqdn==localhost.localdomain" do
            is_expected.to contain_mysql_user(user).with_ensure('absent')
          end
        end
      end
    end
  end
end
