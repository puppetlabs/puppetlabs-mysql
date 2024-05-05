# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::client' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with defaults' do
        it { is_expected.to contain_class('mysql::params') }
        it { is_expected.to contain_class('mysql::client::install') }
        it { is_expected.not_to contain_class('mysql::bindings') }
        it { is_expected.to contain_package('mysql_client') }
      end

      context 'with bindings enabled' do
        let(:params) { { bindings_enable: true } }

        it { is_expected.to contain_class('mysql::bindings') }
        it { is_expected.to contain_package('mysql_client') }
      end

      context 'with package_manage set to true' do
        let(:params) { { package_manage: true } }

        it { is_expected.to contain_package('mysql_client') }
      end

      context 'with package_manage set to false' do
        let(:params) { { package_manage: false } }

        it { is_expected.not_to contain_package('mysql_client') }
      end

      context 'with package provider' do
        let(:params) do
          {
            package_provider: 'dpkg',
            package_source: '/somewhere'
          }
        end

        it do
          is_expected.to contain_package('mysql_client').with(
            provider: 'dpkg',
            source: '/somewhere',
          )
        end
      end
    end
  end
end
