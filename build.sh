#!/bin/bash

# update the version
VERSION=$(./update-version.sh)

# create image ziher-app
docker build . --tag ziher-app:${VERSION}
docker tag ziher-app:${VERSION} ziher-app:latest
