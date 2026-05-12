# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::innobackupex_args' do
  let(:function) { subject }

  it 'exists' do
    expect(function).not_to be_nil
  end

  it 'accepts empty strings as puppet undef' do
    expect(function).to run.with_params('', true, '', [], [])
  end

  context 'should work with username and password' do
    it 'returns args with username and password' do
      expect(function).to run.with_params('root', false, '12345', [], []).and_return('--user="root" --password="12345"')
    end

    it 'returns args with database lists' do
      expect(function).to run.with_params('root', false, '12345', ['db1', 'db2'], []).and_return('--user="root" --password="12345" --databases="db1 db2"')
    end

    it 'returns args with backup compress only' do
      expected_results = '--user="root" --password="12345" --compress'
      expect(function).to run.with_params('root', true, '12345', [], []).and_return(expected_results)
    end

    it 'returns args with backup compress, database list and optional_args' do
      expected_results = '--user="root" --password="12345" --compress --databases="db1 db2" tst_arg_1 tst_arg_2'
      expect(function).to run.with_params('root', true, '12345', ['db1', 'db2'], ['tst_arg_1', 'tst_arg_2']).and_return(expected_results)
    end
  end

  context 'should work without database args' do
    it 'returns args without database list' do
      expect(function).to run.with_params('root', false, '12345', [], []).and_return('--user="root" --password="12345"')
    end
  end

  it 'returns args without backup compress' do
    expect(function).to run.with_params('root', false, '12345', [], []).and_return('--user="root" --password="12345"')
  end

  it 'returns args with backup compress and database list' do
    expected_results = '--user="root" --password="12345" --compress --databases="db1 db2"'
    expect(function).to run.with_params('root', true, '12345', ['db1', 'db2'], []).and_return(expected_results)
  end

  it 'returns args without backup compress database list and optional_args' do
    expected_results = '--user="root" --password="12345" --databases="db1 db2" tst_arg_1 tst_arg_2'
    expect(function).to run.with_params('root', false, '12345', ['db1', 'db2'], ['tst_arg_1', 'tst_arg_2']).and_return(expected_results)
  end

  it 'returns args without backup compress database list and with optional_args' do
    expected_results = '--user="root" --password="12345" tst_arg_1 tst_arg_2'
    expect(function).to run.with_params('root', false, '12345', [], ['tst_arg_1', 'tst_arg_2']).and_return(expected_results)
  end
end
