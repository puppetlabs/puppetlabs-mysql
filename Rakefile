require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet_pot_generator/rake_tasks' if Bundler.rubygems.find_name('puppet_pot_generator').any?
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('relative')

desc 'Generate pooler nodesets'
task :gen_nodeset do
  require 'beaker-hostgenerator'
  require 'securerandom'
  require 'fileutils'

  agent_target = ENV['TEST_TARGET']
  if ! agent_target
    STDERR.puts 'TEST_TARGET environment variable is not set'
    STDERR.puts 'setting to default value of "redhat-64default."'
    agent_target = 'redhat-64default.'
  end

  master_target = ENV['MASTER_TEST_TARGET']
  if ! master_target
    STDERR.puts 'MASTER_TEST_TARGET environment variable is not set'
    STDERR.puts 'setting to default value of "redhat7-64mdcl"'
    master_target = 'redhat7-64mdcl'
  end

  targets = "#{master_target}-#{agent_target}"
  cli = BeakerHostGenerator::CLI.new([targets])
  nodeset_dir = "tmp/nodesets"
  nodeset = "#{nodeset_dir}/#{targets}-#{SecureRandom.uuid}.yaml"
  FileUtils.mkdir_p(nodeset_dir)
  File.open(nodeset, 'w') do |fh|
    fh.print(cli.execute)
  end
  puts nodeset
end
