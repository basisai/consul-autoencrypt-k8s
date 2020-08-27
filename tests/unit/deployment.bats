#!/usr/bin/env bats

load _helpers

@test "deployment: TLS with auto encrypt adds an init container" {
  cd `chart_dir`

  local actual=$(helm template \
      --show-only templates/deployment.yaml  \
      --set 'consul.tls.enabled=false' \
      --set 'consul.tls.autoEncrypt=true' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.initContainers | length' | tee /dev/stderr)

  [ "${actual}" = '0' ]

  local actual=$(helm template \
      --show-only templates/deployment.yaml  \
      --set 'consul.tls.enabled=true' \
      --set 'consul.tls.autoEncrypt=false' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.initContainers | length' | tee /dev/stderr)

  [ "${actual}" = '0' ]

  local actual=$(helm template \
      --show-only templates/deployment.yaml  \
      --set 'consul.tls.enabled=true' \
      --set 'consul.tls.autoEncrypt=true' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.initContainers | length' | tee /dev/stderr)

  [ "${actual}" = '1' ]
}

@test "deployment: Correct Consul Port is set for Consul Template with and without TLS" {
  cd `chart_dir`

  local actual=$(helm template \
      --show-only templates/deployment.yaml  \
      --set 'consul.tls.enabled=false' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].args[0]' | tee /dev/stderr)

  [ "${actual}" = '-consul-addr=$(HOST_IP):8500' ]

  local actual=$(helm template \
      --show-only templates/deployment.yaml  \
      --set 'consul.tls.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].args[0]' | tee /dev/stderr)

  [ "${actual}" = '-consul-addr=$(HOST_IP):8501' ]
}
