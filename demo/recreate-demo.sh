#!/bin/bash

set -x

readonly DB_CONTAINER=demo-db
readonly PGPASSWORD=postgres
readonly DB_PASSWORD=ziherdemo
readonly DB_USER=ziherdemo
readonly DB_NAME=ziherdemo
readonly ZIHER_CONTAINER=demo

docker compose stop demo-db
docker compose rm -f demo-db
docker compose up -d demo-db
sleep 5

docker compose exec -T $DB_CONTAINER bash -c "PGPASSWORD=$PGPASSWORD psql -h localhost -U $PGPASSWORD -d $PGPASSWORD -c \"drop database $DB_NAME\""

docker compose exec -T $DB_CONTAINER bash -c "PGPASSWORD=$PGPASSWORD psql -h localhost -U $PGPASSWORD -d $PGPASSWORD -c \"drop role $DB_USER\""
docker compose exec -T $DB_CONTAINER bash -c "PGPASSWORD=$PGPASSWORD psql -h localhost -U $PGPASSWORD -d $PGPASSWORD -c \"create role $DB_USER with CREATEDB SUPERUSER login password '$DB_PASSWORD'\""

docker compose exec -T $DB_CONTAINER bash -c "PGPASSWORD=$PGPASSWORD psql -h localhost -U $PGPASSWORD -d $PGPASSWORD -c \"create database $DB_NAME with owner $DB_USER\""

docker compose stop ${ZIHER_CONTAINER}
docker compose rm -f ${ZIHER_CONTAINER}
docker compose up -d ${ZIHER_CONTAINER}
sleep 5

docker compose exec -T ${ZIHER_CONTAINER} rake db:create
docker compose exec -T ${ZIHER_CONTAINER} rake db:migrate
docker compose exec -T ${ZIHER_CONTAINER} rake db:seed
