# frozen_string_literal: true

require 'rspec-puppet-facts'
include RspecPuppetFacts

if ENV['COVERAGE'] == 'yes'
  require 'simplecov'
  require 'simplecov-console'
  require 'codecov'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console,
    SimpleCov::Formatter::Codecov,
  ]
  SimpleCov.start do
    track_files 'lib/**/*.rb'

    add_filter '/spec'

    # do not track vendored files
    add_filter '/vendor'
    add_filter '/.vendor'

    # do not track gitignored files
    # this adds about 4 seconds to the coverage check
    # this could definitely be optimized
    add_filter do |f|
      # system returns true if exit status is 0, which with git-check-ignore means file is ignored
      system("git check-ignore --quiet #{f.filename}")
    end
  end
end

# Override facts
# Taken from: https://github.com/voxpupuli/voxpupuli-test/blob/master/lib/voxpupuli/test/facts.rb
#
# This doesn't use deep_merge because that's highly unpredictable. It can merge
# nested hashes in place, modifying the original. It's also unable to override
# true to false.
#
# A deep copy is obtained by using Marshal so it can be modified in place. Then
# it recursively overrides values. If the result is a hash, it's recursed into.
#
# A typical example:
#
# let(:facts) do
#   override_facts(super(), os: {'selinux' => {'enabled' => false}})
# end
def override_facts(base_facts, **overrides)
  facts = Marshal.load(Marshal.dump(base_facts))
  apply_overrides!(facts, overrides, false)
  facts
end

# A private helper to override_facts
def apply_overrides!(facts, overrides, enforce_strings)
  overrides.each do |key, value|
    # Nested facts are strings
    key = key.to_s if enforce_strings

    if value.is_a?(Hash)
      facts[key] = {} unless facts.key?(key)
      apply_overrides!(facts[key], value, true)
    else
      facts[key] = value
    end
  end
end
