# frozen_string_literal: true

require 'puppet_litmus'
require 'spec_helper_acceptance_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_acceptance_local.rb'))

PuppetLitmus.configure!

# On Ubuntu 20.04 'utf8' charset now sets 'utf8mb3' internally and breaks idempotence
$charset = if os[:family] == 'ubuntu' && os[:release] =~ %r{^20\.04}
                "utf8mb3"
             else
               "utf8"
             end
