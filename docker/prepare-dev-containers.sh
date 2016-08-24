#!/bin/bash

sudo service postgresql stop
docker-compose build
docker-compose up -d --force-recreate

psql -h 127.0.0.1 -U postgres -d postgres -c "create user my_db_username with password 'my_db_password'"
psql -h 127.0.0.1 -U postgres -d postgres -c "create database my_db_name with owner my_db_username"

docker exec ziher rake db:migrate
docker exec ziher rake db:seed
