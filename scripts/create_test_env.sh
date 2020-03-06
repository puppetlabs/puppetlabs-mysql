#!/bin/sh
pdk bundle install
pdk bundle exec rake 'litmus:provision[docker, litmusimage/centos:7]'
pdk bundle exec rake litmus:install_agent
pdk bundle exec rake litmus:install_module
