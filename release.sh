#!/bin/bash

readonly RELEASE_TYPE=${1:-prod}

if [[ "${RELEASE_TYPE}" != "prod" && \
      "${RELEASE_TYPE}" != "base" && \
      "${RELEASE_TYPE}" != "all" ]]; then
    echo "Usage: $0 [prod|base|all]"
    exit 1
fi

# update the version
VERSION=$(./update-version.sh)

release_prod() {
    docker push ziher/app:${VERSION}

    docker tag ziher/app:${VERSION} ziher/app:latest
    docker push ziher/app:latest
}

release_base() {
    docker push ziher/base:${VERSION}

    docker tag ziher/base:${VERSION} ziher/base:latest
    docker push ziher/base:latest
}

case "${RELEASE_TYPE}" in
    prod)
        echo "Releasing production image..."
        release_prod
        ;;
    base)
        echo "Releasing base image..."
        release_base
        ;;
    all)
        echo "Releasing all images..."
        release_base
        release_prod
        ;;
esac