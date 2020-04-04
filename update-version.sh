#!/bin/bash

# Do not user SemVer and use commit date and hash instead.
# This is not intended to be used by third parties as a library or an app.
# The only build number that makes sense for the users is when was the last code change.

COMMIT_DATE=$(git show --no-patch --format=%cd --date=short HEAD)

read YEAR MONTH DAY < <(echo ${COMMIT_DATE//-/\ })

GIT_HASH=$(git rev-parse --short HEAD)

VERSION_FILE="config/initializers/version.rb"
VERSION_STRING="VERSION = [\"${YEAR}\", \"${MONTH}\", \"${DAY}\", \"${GIT_HASH}\"]"
echo $VERSION_STRING > $VERSION_FILE

echo ${YEAR}.${MONTH}.${DAY}-${GIT_HASH}
