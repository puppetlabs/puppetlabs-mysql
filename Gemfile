source :rubygems

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 2.7']

gem 'puppet', puppetversion
gem 'hiera', '>= 0.3.0'
gem 'hiera-puppet', '>= 0.3.0'

group :test do
  gem 'rake', '>= 0.9.0'
  gem 'rspec', '>= 2.8.0'
  gem 'rspec-puppet', '>= 0.1.1'
end
