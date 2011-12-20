require 'rake'
require 'fileutils'

begin
  require 'rspec/core/rake_task'
  HAVE_RSPEC = true
rescue LoadError
  HAVE_RSPEC = false
end

task :default => [:build]

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

if HAVE_RSPEC then
  desc 'Run all module spec tests (Requires rspec-puppet gem)'
  task :spec do
    system 'rspec --format d spec/'
  end
end
