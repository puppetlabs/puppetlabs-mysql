source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place_or_version, fake_version = nil)
  git_url_regex = %r{\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?}
  file_url_regex = %r{\Afile:\/\/(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

group :development do
  gem "json", '~> 2.0',                                     require: false
  gem "voxpupuli-puppet-lint-plugins", '~> 3.0',            require: false
  gem "facterdb", '~> 1.18',                                require: false
  gem "metadata-json-lint", '>= 2.0.2', '< 4.0.0',          require: false
  gem "puppetlabs_spec_helper", '>= 3.0.0', '< 5.0.0',      require: false
  gem "rspec-puppet-facts", '~> 2.0',                       require: false
  gem "codecov", '~> 0.2',                                  require: false
  gem "dependency_checker", '~> 0.2',                       require: false
  gem "parallel_tests", '~> 3.4',                           require: false
  gem "pry", '~> 0.10',                                     require: false
  gem "simplecov-console", '~> 0.5',                        require: false
  gem "puppet-debugger", '~> 1.0',                          require: false
  gem "rubocop", '= 1.6.1',                                 require: false
  gem "rubocop-performance", '= 1.9.1',                     require: false
  gem "rubocop-rspec", '= 2.0.1',                           require: false
  gem "rb-readline", '= 0.5.5',                             require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "github_changelog_generator",                         require: false
  gem 'puppet-lint-check_unsafe_interpolations', '~> 0.0.3' require: false
end
group :system_tests do
  gem "puppet_litmus", '< 1.0.0', require: false, platforms: [:ruby]
  gem "serverspec", '~> 2.41',    require: false
end

puppet_version = ENV['PUPPET_GEM_VERSION']
facter_version = ENV['FACTER_GEM_VERSION']
hiera_version = ENV['HIERA_GEM_VERSION']

gems = {}

gems['puppet'] = location_for(puppet_version)

# If facter or hiera versions have been specified via the environment
# variables

gems['facter'] = location_for(facter_version) if facter_version
gems['hiera'] = location_for(hiera_version) if hiera_version

gems.each do |gem_name, gem_params|
  gem gem_name, *gem_params
end

# Evaluate Gemfile.local and ~/.gemfile if they exist
extra_gemfiles = [
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]

extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end
# vim: syntax=ruby
