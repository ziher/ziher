#!/bin/bash

# http://semver.org/
# Updates VERSION. Use MAJOR_VERSION, MINOR_VERSION, PATCH_VERSION, BUILD_VERSION to override defaults"


MAJOR=${MAJOR_VERSION:-2}
MINOR=${MINOR_VERSION:-0}
PATCH=${PATCH_VERSION:-0}
BUILD=${BUILD_VERSION:-`git describe --always`}

VERSION_FILE="config/initializers/version.rb"
VERSION_STRING="VERSION = [\"${MAJOR}\", \"${MINOR}\", \"${PATCH}\", \"${BUILD}\"]"

echo $VERSION_STRING
echo $VERSION_STRING > $VERSION_FILE
