require 'pry'
require 'rspec-puppet-facts'
include RspecPuppetFacts

add_custom_fact :root_home, '/root'
add_custom_fact :mysql_solaris,
  {
    'major_dot_minor' => '5.7',
    'major_minor' => '57',
    'basedir' => '/usr/mysql/5.7'
  }
