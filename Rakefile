require 'rake'
require 'rspec/core/rake_task'
require 'yaml'

task :default => [:spec]

desc "Run all module spec tests (Requires rspec-puppet gem)"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'spec/{classes,defines,unit}/**/*_spec.rb'
end

# This is a helper for the self-symlink entry of fixtures.yml
def source_dir
  File.dirname(__FILE__)
end

def fixtures(category)
  begin
    fixtures = YAML.load_file(".fixtures.yml")["fixtures"]
  rescue Errno::ENOENT
    return {}
  end

  if not fixtures
    abort("malformed fixtures.yml")
  end

  result = {}
  if fixtures.include? category
    fixtures[category].each do |fixture, source|
      target = "spec/fixtures/modules/#{fixture}"
      real_source = eval('"'+source+'"')
      result[real_source] = target
    end
  end
  return result
end

desc "Create the fixtures directory"
task :spec_prep do
  fixtures("repositories").each do |repo, target|
    File::exists?(target) || system("git clone #{repo} #{target}")
  end

  FileUtils::mkdir_p("spec/fixtures/modules")
  fixtures("symlinks").each do |source, target|
    File::exists?(target) || FileUtils::ln_s(source, target)
  end
end

desc "Clean up the fixtures directory"
task :spec_clean do
  fixtures("repositories").each do |repo, target|
    FileUtils::rm_rf(target)
  end

  fixtures("symlinks").each do |source, target|
    FileUtils::rm(target)
  end
end

task :spec_full do
  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec].invoke
  Rake::Task[:spec_clean].invoke
end

desc "Build puppet module package"
task :build do
  # This will be deprecated once puppet-module is a face.
  begin
    Gem::Specification.find_by_name('puppet-module')
  rescue Gem::LoadError, NoMethodError
    require 'puppet/face'
    pmod = Puppet::Face['module', :current]
    pmod.build('./')
  end
end

desc "Clean a built module package"
task :clean do
  FileUtils.rm_rf("pkg/")
end

desc "Check puppet manifests with puppet-lint"
task :lint do
  # This requires pull request: https://github.com/rodjek/puppet-lint/pull/81
  system("puppet-lint manifests")
  system("puppet-lint tests")
end
