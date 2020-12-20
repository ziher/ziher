#!/bin/bash

sudo service postgresql stop
docker-compose build
docker-compose up -d --force-recreate

psql -h 127.0.0.1 -U postgres -d postgres -c "create user ziher with password 'ziher'"
psql -h 127.0.0.1 -U postgres -d postgres -c "create database ziher_development with owner ziher"

docker exec ziher rake db:migrate
docker exec ziher rake db:seed
