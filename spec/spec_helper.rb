require 'rubygems'
require 'puppet'
require 'rspec-puppet'

def param_value(subject, type, title, param)
  subject.resource(type, title).send(:parameters)[param.to_sym]
end

Puppet.parse_config
puppet_module_path = Puppet[:modulepath]

fixture_path = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))

RSpec.configure do |c|
  fixture_module_path = File.join(fixture_path, 'modules')
  c.module_path = [fixture_module_path, puppet_module_path].join(":")
  c.manifest_dir = File.join(fixture_path, 'manifests')
end
