# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::server' do
  context 'on an unsupported OS' do
    let(:facts) do
      {
        os: { family: 'UNSUPPORTED',
              name: 'UNSUPPORTED' },
      }
    end

    it 'gracefully fails' do
      is_expected.to compile.and_raise_error(%r{Unsupported platform:})
    end
  end
end
