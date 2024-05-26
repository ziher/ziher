#!/bin/bash

# update the version
VERSION=$(./update-version.sh)

# create image ziher/app
docker build . --build-arg SECRET_KEY_BASE=dummykeybase --target ziher-prod --tag ziher/app:${VERSION}
docker tag ziher/app:${VERSION} ziher/app:latest

docker build . --build-arg SECRET_KEY_BASE=dummykeybase --target ziher-dev --tag ziher/app:${VERSION}-dev
docker tag ziher/app:${VERSION}-dev ziher/app:latest-dev
