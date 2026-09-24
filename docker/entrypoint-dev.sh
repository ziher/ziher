#!/bin/bash

set -euo pipefail

cd /ziher

if [ "$#" -gt 0 ]; then
  exec "$@"
fi

echo
echo "--------- ZiHeR application start"
echo
echo "--------- BUILD $(cat config/initializers/version.rb)"

bundle exec rails db:prepare
bundle exec rails runner "Rails.application.load_seed unless User.exists?"

exec bundle exec rails server -u webrick -b 0.0.0.0
