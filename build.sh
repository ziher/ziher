#!/bin/bash

# update the version
VERSION=$(./update-version.sh)

# create image ziher-app
docker build . --build-arg SECRET_KEY_BASE=dummykeybase --tag ziher-app:${VERSION}
docker tag ziher-app:${VERSION} ziher-app:latest
