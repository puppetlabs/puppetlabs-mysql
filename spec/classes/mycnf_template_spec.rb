# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::server' do
  on_supported_os.each do |os, facts|
    context "my.cnf template - on #{os}" do
      let(:facts) do
        facts.merge(root_home: '/root')
      end

      context 'normal entry' do
        let(:params) { { override_options: { 'mysqld' => { 'socket' => '/var/lib/mysql/mysql.sock' } } } }

        it do
          expect(subject).to contain_file('mysql-config-file').with(mode: '0644',
                                                                    selinux_ignore_defaults: true).with_content(%r{socket = \/var\/lib\/mysql\/mysql.sock})
        end
      end

      describe 'array entry' do
        let(:params) { { override_options: { 'mysqld' => { 'replicate-do-db' => ['base1', 'base2'] } } } }

        it do
          expect(subject).to contain_file('mysql-config-file').with_content(
            %r{.*replicate-do-db = base1\nreplicate-do-db = base2.*},
          )
        end
      end

      describe 'skip-name-resolve set to an empty string' do
        let(:params) { { override_options: { 'mysqld' => { 'skip-name-resolve' => '' } } } }

        it { is_expected.to contain_file('mysql-config-file').with_content(%r{^skip-name-resolve$}) }
      end

      describe 'ssl set to true' do
        let(:params) { { override_options: { 'mysqld' => { 'ssl' => true } } } }

        it { is_expected.to contain_file('mysql-config-file').with_content(%r{ssl}) }
        it { is_expected.to contain_file('mysql-config-file').without_content(%r{ssl = true}) }
      end

      describe 'ssl set to false' do
        let(:params) { { override_options: { 'mysqld' => { 'ssl' => false } } } }

        it { is_expected.to contain_file('mysql-config-file').with_content(%r{ssl = false}) }
      end

      describe 'ssl set to false filters out ssl options' do
        let(:params) { { override_options: { 'mysqld' => { 'ssl' => false, 'ssl-disable' => false, 'ssl-key' => '/etc/key.pem' } } } }

        it { is_expected.to contain_file('mysql-config-file').with_content(%r{ssl = false}) }
        it { is_expected.to contain_file('mysql-config-file').without_content(%r{ssl-key}) }
      end

      # ssl-disable (and ssl) are special cased within mysql.
      describe 'possibility of disabling ssl completely' do
        let(:params) { { override_options: { 'mysqld' => { 'ssl' => true, 'ssl-disable' => true } } } }

        it { is_expected.to contain_file('mysql-config-file').without_content(%r{ssl = true}) }
      end

      describe 'ssl-disable filters other ssl options' do
        let(:params) { { override_options: { 'mysqld' => { 'ssl' => true, 'ssl-disable' => true, 'ssl-key' => '/etc/key.pem' } } } }

        it { is_expected.to contain_file('mysql-config-file').without_content(%r{ssl = true}) }
        it { is_expected.to contain_file('mysql-config-file').without_content(%r{ssl-disable}) }
        it { is_expected.to contain_file('mysql-config-file').without_content(%r{ssl-key}) }
      end

      describe 'a non ssl option set to true' do
        let(:params) { { override_options: { 'mysqld' => { 'test' => true } } } }

        it { is_expected.to contain_file('mysql-config-file').with_content(%r{^test$}) }
        it { is_expected.to contain_file('mysql-config-file').without_content(%r{test = true}) }
      end

      context 'with includedir' do
        let(:params) { { includedir: '/etc/my.cnf.d' } }

        it 'makes the directory' do
          expect(subject).to contain_file('/etc/my.cnf.d').with(ensure: :directory,
                                                                mode: '0755')
        end

        it { is_expected.to contain_file('mysql-config-file').with_content(%r{!includedir}) }
      end

      context 'without includedir' do
        let(:params) { { includedir: '' } }

        it 'shouldnt contain the directory' do
          expect(subject).not_to contain_file('mysql-config-file').with(ensure: :directory,
                                                                        mode: '0755')
        end

        it { is_expected.to contain_file('mysql-config-file').without_content(%r{!includedir}) }
      end

      context 'with file mode 0644' do
        let(:params) { { 'config_file_mode' => '0644' } }

        it do
          expect(subject).to contain_file('mysql-config-file').with(mode: '0644')
        end
      end

      context 'with file mode 0664' do
        let(:params) { { 'config_file_mode' => '0664' } }

        it do
          expect(subject).to contain_file('mysql-config-file').with(mode: '0664')
        end
      end

      context 'with file mode 0660' do
        let(:params) { { 'config_file_mode' => '0660' } }

        it do
          expect(subject).to contain_file('mysql-config-file').with(mode: '0660')
        end
      end

      context 'with file mode 0641' do
        let(:params) { { 'config_file_mode' => '0641' } }

        it do
          expect(subject).to contain_file('mysql-config-file').with(mode: '0641')
        end
      end

      context 'with file mode 0610' do
        let(:params) { { 'config_file_mode' => '0610' } }

        it do
          expect(subject).to contain_file('mysql-config-file').with(mode: '0610')
        end
      end

      context 'with file 0600' do
        let(:params) { { 'config_file_mode' => '0600' } }

        it do
          expect(subject).to contain_file('mysql-config-file').with(mode: '0600')
        end
      end

      context 'user owner 12345' do
        let(:params) { { 'mycnf_owner' => '12345' } }

        it do
          expect(subject).to contain_file('mysql-config-file').with(
            owner: '12345',
          )
        end
      end

      context 'group owner 12345' do
        let(:params) { { 'mycnf_group' => '12345' } }

        it do
          expect(subject).to contain_file('mysql-config-file').with(
            group: '12345',
          )
        end
      end

      context 'user and group owner 12345' do
        let(:params) { { 'mycnf_owner' => '12345', 'mycnf_group' => '12345' } }

        it do
          expect(subject).to contain_file('mysql-config-file').with(
            owner: '12345',
            group: '12345',
          )
        end
      end
    end
  end
end
