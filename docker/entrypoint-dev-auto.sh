#!/bin/bash
set -e

cd /ziher

echo "--------- ZiHeR dev (auto) start"
echo "--------- BUILD $(cat config/initializers/version.rb 2>/dev/null || echo 'unknown')"

if [ ! -d /usr/local/bundle/gems ] || ! bundle check >/dev/null 2>&1; then
  echo "--------- Installing missing gems"
  bundle install
fi

echo "--------- Preparing database (create / migrate / seed if needed)"
bundle exec rails db:prepare

echo "--------- Starting Rails server on 0.0.0.0:3000"
exec bundle exec rails server -u webrick -b 0.0.0.0 -p 3000
