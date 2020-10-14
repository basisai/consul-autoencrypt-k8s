#!/usr/bin/env bats

load _helpers

@test "configmap: TLS is enabled correctly" {
  cd `chart_dir`

  local config=$(helm template \
      --show-only templates/configmap.yaml  \
      --set 'consul.tls.enabled=false' \
      --set 'consul.tls.autoEncrypt=true' \
      . | tee /dev/stderr |
      yq -r '.data."consul_template.hcl"' | tee /dev/stderr)

  local actual=$(echo "${config}" |
      grep -Pzo 'consul {\s+ssl {\s+enabled = true\s+' | tee /dev/stderr |
      wc -l | tee /dev/stderr)

  [ "${actual}" = '0' ]

  local config=$(helm template \
      --show-only templates/configmap.yaml  \
      --set 'consul.tls.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.data."consul_template.hcl"' | tee /dev/stderr)

  local actual=$(echo "${config}" |
      grep -Pzo 'consul {\s+ssl {\s+enabled = true\s+' | tee /dev/stderr |
      wc -l | tee /dev/stderr)

  [ "${actual}" = '3' ]
}

@test "configmap: 'ca_cert' is configured correctly" {
  cd `chart_dir`

  # Neither CACert nor Auto Encrypt
  local config=$(helm template \
      --show-only templates/configmap.yaml  \
      --set 'consul.tls.enabled=true' \
      --set 'consul.tls.autoEncrypt=false' \
      --set 'consul.server.caCert=null' \
      . | tee /dev/stderr |
      yq -r '.data."consul_template.hcl"' | tee /dev/stderr)

  local actual=$(echo "${config}" |
      grep -Pzo '(?s)consul {\s+ssl {.+ca_cert = "/output/connect.pem"\s+' | tee /dev/stderr |
      wc -l | tee /dev/stderr)
  [ "${actual}" = '0' ]
  local actual=$(echo "${config}" |
      grep -Pzo '(?s)consul {\s+ssl {.+ca_cert = "/config/server.pem"\s+' | tee /dev/stderr |
      wc -l | tee /dev/stderr)
  [ "${actual}" = '0' ]

  # CACert Set
  local config=$(helm template \
      --show-only templates/configmap.yaml  \
      --set 'consul.tls.enabled=true' \
      --set 'consul.tls.autoEncrypt=true' \
      --set 'consul.server.caCert=null' \
      . | tee /dev/stderr |
      yq -r '.data."consul_template.hcl"' | tee /dev/stderr)

  local actual=$(echo "${config}" |
      grep -Pzo '(?s)consul {\s+ssl {.+ca_cert = "/output/connect.pem"\s+' | tee /dev/stderr |
      wc -l | tee /dev/stderr)
  [ "${actual}" = '4' ]
  local actual=$(echo "${config}" |
      grep -Pzo '(?s)consul {\s+ssl {.+ca_cert = "/config/server.pem"\s+' | tee /dev/stderr |
      wc -l | tee /dev/stderr)
  [ "${actual}" = '0' ]

  # Auto Encrypt enabled
  local config=$(helm template \
      --show-only templates/configmap.yaml  \
      --set 'consul.tls.enabled=true' \
      --set 'consul.tls.autoEncrypt=false' \
      --set 'consul.server.caCert=foobar' \
      . | tee /dev/stderr |
      yq -r '.data."consul_template.hcl"' | tee /dev/stderr)

  local actual=$(echo "${config}" |
      grep -Pzo '(?s)consul {\s+ssl {.+ca_cert = "/output/connect.pem"\s+' | tee /dev/stderr |
      wc -l | tee /dev/stderr)
  [ "${actual}" = '0' ]
  local actual=$(echo "${config}" |
      grep -Pzo '(?s)consul {\s+ssl {.+ca_cert = "/config/server.pem"\s+' | tee /dev/stderr |
      wc -l | tee /dev/stderr)
  [ "${actual}" = '4' ]
}
