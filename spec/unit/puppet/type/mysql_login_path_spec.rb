# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/mysql_login_path'

RSpec.describe 'the mysql_login_path type' do
  it 'loads' do
    expect(Puppet::Type.type(:mysql_login_path)).not_to be_nil
  end
end
