#!/bin/sh
#pdk bundle install
#pdk bundle exec rake 'litmus:provision[docker, travis_deb]'
pdk bundle exec rake 'litmus:provision_list[travis_deb]'
pdk bundle exec rake litmus:install_agent
pdk bundle exec rake litmus:install_module
