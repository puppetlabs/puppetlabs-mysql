require 'spec_helper'

describe 'mysql::server' do
  on_pe_unsupported_platforms.each do |pe_version,pe_platforms|
    pe_platforms.each do |pe_platform,facts|
      describe "on #{pe_version} #{pe_platform}" do
        let(:facts) { facts }

        context 'should gracefully fail' do
          it { should_not contain_class('mysql::server') }
          it { should raise_error(/Unsupported osfamily: foo/) }
        end
      end
    end
  end
end
