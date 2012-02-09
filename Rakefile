require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'fileutils'

task :default do
  system("rake -T")
end

desc "Run all rspec-puppet tests"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--color']
  # ignores fixtures directory.
  t.pattern = 'spec/{classes,defines,unit}/**/*_spec.rb'
end

def update_module_version
  gitdesc = %x{git describe}.chomp
  semver = gitdesc.gsub(/v?(\d+\.\d+\.\d+)-?(.*)/) do
    newver = "#{$1}"
    newver << "git-#{$2}" unless $2.empty?
    newver
  end
  modulefile = File.read("Modulefile")
  modulefile.gsub!(/^\s*version\s+'.*?'/, "version '#{semver}'")
  File.open("Modulefile", 'w') do |f|
    f.write(modulefile)
  end
  semver
end

desc "Build Puppet Module Package"
task :build do
  system("gimli README*.markdown")
  FileUtils.cp "Modulefile", "Modulefile.bak"
  update_module_version
  system("puppet-module build")
  FileUtils.mv "Modulefile.bak", "Modulefile"
end

desc "Clean the package directory"
task :clean do
  FileUtils.rm_rf("pkg/")
end

desc "Check puppet manifests with puppet-lint"
task :lint do
  # This requires pull request: https://github.com/rodjek/puppet-lint/pull/81
  system("puppet-lint manifests")
  system("puppet-lint tests")
end
