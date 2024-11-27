#!/bin/bash

echo
echo --------- ZiHeR application start
echo
echo --------- BUILD $(cat config/initializers/version.rb)

echo
echo "--> Cleaning previously precompiled assets"
rake assets:clobber --trace RAILS_RELATIVE_URL_ROOT=/
rake tmp:cache:clear

echo
echo "--> Precompiling new assets"
rake assets:precompile --trace

exec passenger start -p 3000 -a 0.0.0.0
