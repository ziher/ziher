#!/bin/bash

set -x

readonly DB_CONTAINER=postgres
readonly PGPASSWORD=postgres
readonly DB_PASSWORD=ziher
readonly DB_USER=ziher

# this whole script should be something like: rake db:reset

for ziherenv in development stage; do
  DB_NAME="ziher_${ziherenv}"

  docker compose --project-directory /ziher/docker/ exec -T $DB_CONTAINER bash -c "PGPASSWORD=$PGPASSWORD psql -h localhost -U postgres -d postgres -c \"drop database $DB_NAME\""
	# rether should be: rake db:drop:all
done

docker compose --project-directory /ziher/docker/ exec -T $DB_CONTAINER bash -c "PGPASSWORD=$PGPASSWORD psql -h localhost -U postgres -d postgres -c \"drop role $DB_USER\""
docker compose --project-directory /ziher/docker/ exec -T $DB_CONTAINER bash -c "PGPASSWORD=$PGPASSWORD psql -h localhost -U postgres -d postgres -c \"create role $DB_USER with CREATEDB SUPERUSER login password '$DB_PASSWORD'\""

for ziherenv in development stage; do
  DB_NAME="ziher_${ziherenv}"

  docker compose --project-directory /ziher/docker/ exec -T $DB_CONTAINER bash -c "PGPASSWORD=$PGPASSWORD psql -h localhost -U postgres -d postgres -c \"create database $DB_NAME with owner $DB_USER\""
  # rather should be: rake db:create:all
done
