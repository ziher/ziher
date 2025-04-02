#!/bin/bash

readonly BUILD_ENVIRONMENT=${1:-prod}

if [[ "${BUILD_ENVIRONMENT}" != "prod" && \
      "${BUILD_ENVIRONMENT}" != "dev" && \
      "${BUILD_ENVIRONMENT}" != "base" && \
      "${BUILD_ENVIRONMENT}" != "all" ]]; then
    echo "Usage: $0 [prod|dev|base|all]"
    exit 1
fi

# update the version
VERSION=$(./update-version.sh)

build_prod() {
    docker build . --build-arg SECRET_KEY_BASE=dummykeybase --target ziher-prod --tag ziher/app:${VERSION}
    docker tag ziher/app:${VERSION} ziher/app:latest
}

build_dev() {
    docker build . --build-arg SECRET_KEY_BASE=dummykeybase --target ziher-dev --tag ziher/app:${VERSION}-dev
    docker tag ziher/app:${VERSION}-dev ziher/app:latest-dev
}

build_base() {
    docker build --file Dockerfile.base . --target ziher-base --tag ziher/base:${VERSION}
    docker tag ziher/base:${VERSION} ziher/base:latest
}

case "${BUILD_ENVIRONMENT}" in
    prod)
        echo "Building production image..."
        build_prod
        ;;
    dev)
        echo "Building development image..."
        build_dev
        ;;
    base)
        echo "Building base image..."
        build_base
        ;;
    all)
        echo "Building all images..."
        build_base
        build_prod
        build_dev
        ;;
esac