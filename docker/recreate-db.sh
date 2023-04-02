#!/bin/bash

set -x

readonly DB_CONTAINER=postgres
readonly PGPASSWORD=postgres
readonly DB_NAME=ziher_development
readonly DB_PASSWORD=ziher
readonly DB_USER=ziher

for ziherenv in development stage; do
  DB_NAME="ziher_${ziherenv}"

  docker compose exec -T $DB_CONTAINER bash -c "PGPASSWORD=$PGPASSWORD psql -h localhost -U postgres -d postgres -c \"drop database $DB_NAME\""
  docker compose exec -T $DB_CONTAINER bash -c "PGPASSWORD=$PGPASSWORD psql -h localhost -U postgres -d postgres -c \"drop user $DB_USER\""
  docker-compose exec -T $DB_CONTAINER bash -c "PGPASSWORD=$PGPASSWORD psql -h localhost -U postgres -d postgres -c \"create user $DB_USER with password '$DB_PASSWORD' createdb\""
  docker compose exec -T $DB_CONTAINER bash -c "PGPASSWORD=$PGPASSWORD psql -h localhost -U postgres -d postgres -c \"create database $DB_NAME with owner $DB_USER\""
done
