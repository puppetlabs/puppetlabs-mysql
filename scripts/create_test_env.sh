#!/bin/sh
#pdk bundle install
pdk bundle exec rake 'litmus:provision_list[travis_deb]'
#pdk bundle exec rake 'litmus:provision_list[travis_ub]'
#pdk bundle exec rake 'litmus:provision_list[travis_el6]'
#pdk bundle exec rake 'litmus:provision_list[travis_el7]'
#pdk bundle exec rake 'litmus:provision_list[travis_el8]'
pdk bundle exec rake 'litmus:install_agent[puppet6]'
pdk bundle exec rake litmus:install_module
