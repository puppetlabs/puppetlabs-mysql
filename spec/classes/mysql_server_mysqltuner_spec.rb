require 'spec_helper'

describe 'mysql::server::mysqltuner' do
  on_pe_supported_platforms(PLATFORMS).each do |pe_version,pe_platforms|
    pe_platforms.each do |pe_platform,facts|
      describe "on #{pe_version} #{pe_platform}" do
        let(:facts) { facts }

        it { is_expected.to contain_file('/usr/local/bin/mysqltuner') }
      end
    end
  end
end
