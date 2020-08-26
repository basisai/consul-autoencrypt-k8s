#!/usr/bin/env bash
set -euo pipefail

TEST_IMAGE="${TEST_IMAGE:-quay.io/helmpack/chart-testing:v3.0.0}"

docker run --rm -v "$(pwd):/charts" --workdir "/charts" \
    "${TEST_IMAGE}" \
    ct lint --all --config tests/ct.yaml
