#!/bin/sh
pdk bundle exec rake litmus:reinstall_module && \
#pdk test unit --tests=spec/unit/puppet/type/mysql_login_path_spec.rb
#pdk test unit --tests=spec/unit/puppet/provider/mysql_login_path/mysql_login_path_spec.rb
#RSPEC_DEBUG=1 TARGET_HOST=localhost:2222 pdk bundle exec rspec ./spec/acceptance/types/mysql_login_path_spec.rb
#RSPEC_DEBUG=1 TARGET_HOST=localhost:2223 pdk bundle exec rspec ./spec/acceptance/types/mysql_login_path_spec.rb
#RSPEC_DEBUG=1 TARGET_HOST=localhost:2224 pdk bundle exec rspec ./spec/acceptance/types/mysql_login_path_spec.rb
pdk bundle exec rake litmus:acceptance:localhost:2222
#pdk bundle exec rake litmus:acceptance:localhost:2223
#pdk bundle exec rake litmus:acceptance:localhost:2224
