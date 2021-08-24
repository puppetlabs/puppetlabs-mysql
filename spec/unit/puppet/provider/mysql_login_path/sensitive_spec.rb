# frozen_string_literal: true

require 'spec_helper'
require 'puppet/provider/mysql_login_path/sensitive'
require 'psych'

RSpec.describe Puppet::Provider::MysqlLoginPath::Sensitive do
  subject(:sensitive) { described_class.new('secret') }

  describe 'Puppet::Provider::MysqlLoginPath::Sensitive' do
    it 'encodes its value correctly into transactionstore.yaml' do
      psych_encoded = Psych.load(Psych.dump(sensitive))
      expect(psych_encoded).to eq 'Puppet::Provider::MysqlLoginPath::Sensitive <<encrypted>>'
    end
  end
end
