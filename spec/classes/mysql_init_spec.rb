require 'spec_helper'

describe 'mysql' do
  let(:facts) { {:operatingsystem => 'Unknown'} }

  it { should contain_class 'mysql' }
end
