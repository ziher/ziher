#!/bin/bash

set -euo pipefail

case "${1:-prod}" in
  prod)
    make build-prod
    ;;
  dev)
    make build-dev
    ;;
  *)
    echo "Usage: $0 [prod|dev]" >&2
    exit 1
    ;;
esac
