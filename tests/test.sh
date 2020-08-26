#!/usr/bin/env bash
set -euo pipefail

BATS_IMAGE="${BATS_IMAGE:-basisai/bats-helm:v1.2.1}"

docker run --rm -v "$(git rev-parse --show-toplevel):/tests" --workdir "/tests" \
    "${BATS_IMAGE}" \
    bats tests/unit
