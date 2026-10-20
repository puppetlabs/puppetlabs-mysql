# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::caching_sha2_password' do
  it 'exists' do
    expect(subject).not_to be_nil
  end

  it 'returns a deterministic 0x hash for plaintext' do
    expect(subject).to run.with_params('password').and_return(%r{\A0x[A-F0-9]+\z})
  end

  it 'returns an existing hex hash unchanged' do
    existing = '0x24412430303524'
    expect(subject).to run.with_params(existing).and_return(existing)
  end

  it 'accepts a Sensitive password' do
    plain = subject.execute('password')
    expect(subject).to run.with_params(sensitive('password')).and_return(plain)
  end
end
