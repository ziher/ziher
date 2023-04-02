#!/bin/bash

echo
echo --------- ZiHeR application start
echo
echo --------- BUILD $(cat config/initializers/version.rb)

exec rails server -b 0.0.0.0
