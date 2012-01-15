require 'puppet'
require 'rubygems'
require 'mocha'
require 'rspec'
require 'rspec-puppet'

RSpec.configure do |c|
  c.mock_with :mocha
  c.module_path = File.join(File.dirname(__FILE__), '../../')
end
