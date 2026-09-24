#!/bin/bash

set -euo pipefail

if [ "${1:-prod}" != "prod" ]; then
  echo "Usage: $0 [prod]" >&2
  exit 1
fi

VERSION="$(./update-version.sh)"

docker tag ziher/app:latest "ziher/app:${VERSION}"
docker push "ziher/app:${VERSION}"
docker push ziher/app:latest
