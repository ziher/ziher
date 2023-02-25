#!/bin/bash

# update the version
VERSION=$(./update-version.sh)

docker push ziher/app:${VERSION}

docker tag ziher/app:${VERSION} ziher/app:latest
docker push ziher/app:latest
