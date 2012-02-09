require 'spec_helper'

describe 'mysql' do
  let :facts do
    { :osfamily => 'Debian'}
  end

  it { should contain_class 'mysql' }
end
