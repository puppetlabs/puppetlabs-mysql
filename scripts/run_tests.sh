#!/bin/sh
pdk bundle exec rake litmus:reinstall_module && \
pdk bundle exec rake litmus:acceptance:parallel