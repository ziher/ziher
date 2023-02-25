#!/bin/bash

# update the version
VERSION=$(./update-version.sh)

docker push ziher/app:${VERSION}
