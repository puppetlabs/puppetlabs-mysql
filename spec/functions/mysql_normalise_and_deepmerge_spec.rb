# frozen_string_literal: true

require 'spec_helper'

describe 'mysql::normalise_and_deepmerge' do
  it 'exists' do
    is_expected.not_to be_nil
  end

  it 'throws error with no arguments' do
    is_expected.to run.with_params.and_raise_error(Puppet::ParseError)
  end

  it 'throws error with only one argument' do
    is_expected.to run.with_params('one' => 1).and_raise_error(Puppet::ParseError)
  end

  it 'accepts empty strings as puppet undef' do
    is_expected.to run.with_params({}, '')
  end

  it 'merge two hashes' do
    is_expected.to run.with_params(
      { 'one' => '1', 'two' => '1' }, 'two' => '2', 'three' => '2'
    ).and_return(
      { 'one' => '1', 'two' => '2', 'three' => '2' },
    )
  end

  it 'merges multiple hashes' do
    is_expected.to run.with_params(
      { 'one' => 1 }, { 'one' => '2' }, 'one' => '3'
    ).and_return(
      { 'one' => '3' },
    )
  end

  it 'accepts empty hashes' do
    is_expected.to run.with_params({}, {}, {}).and_return({})
  end

  it 'merges subhashes' do
    is_expected.to run.with_params(
      { 'one' => 1 }, 'two' => 2, 'three' => { 'four' => 4 }
    ).and_return(
      { 'one' => 1, 'two' => 2, 'three' => { 'four' => 4 } },
    )
  end

  it 'appends to subhashes' do
    is_expected.to run.with_params(
      { 'one' => { 'two' => 2 } }, 'one' => { 'three' => 3 }
    ).and_return(
      { 'one' => { 'two' => 2, 'three' => 3 } },
    )
  end

  it 'appends to subhashes 2' do
    is_expected.to run.with_params(
      { 'one' => 1, 'two' => 2, 'three' => { 'four' => 4 } }, 'two' => 'dos', 'three' => { 'five' => 5 }
    ).and_return(
      { 'one' => 1, 'two' => 'dos', 'three' => { 'four' => 4, 'five' => 5 } },
    )
  end

  it 'appends to subhashes 3' do
    is_expected.to run.with_params(
      { 'key1' => { 'a' => 1, 'b' => 2 }, 'key2' => { 'c' => 3 } }, 'key1' => { 'b' => 99 }
    ).and_return(
      { 'key1' => { 'a' => 1, 'b' => 99 }, 'key2' => { 'c' => 3 } },
    )
  end

  it 'equates keys mod dash and underscore #value' do
    is_expected.to run.with_params(
      { 'a-b-c' => 1 }, 'a_b_c' => 10
    ).and_return(
      { 'a_b_c' => 10 },
    )
  end

  it 'keeps style of the last when keys are equal mod dash and underscore #value' do
    is_expected.to run.with_params(
      { 'a-b-c' => 1, 'b_c_d' => { 'c-d-e' => 2, 'e-f-g' => 3 } }, 'a_b_c' => 10, 'b-c-d' => { 'c_d_e' => 12 }
    ).and_return(
      { 'a_b_c' => 10, 'b-c-d' => { 'e-f-g' => 3, 'c_d_e' => 12 } },
    )
  end
end
