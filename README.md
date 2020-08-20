# Consul AutoEncrypt K8S

This repository contains a deployment using
[Consul Template](https://github.com/hashicorp/consul-template) to continuously poll
Consul Connect [CA Roots](https://www.consul.io/api-docs/connect/ca#list-ca-root-certificates) and
then update `ConfigMap`s in Kubernetes in one namespace or more with the CA roots.

These `ConfigMap`s can then be mounted directly into your pods that require the CA to talk to Consul
Agents.

This setup works well with a Consul Cluster deployed via the official
[HashiCorp Consul Helm Chart](https://github.com/hashicorp/consul-helm).

## Docker Image

The docker image located in `docker/` is basically just Consul Template with `kubectl` installled.

It is pushed to
[`basisai/consul-autoencrypt-k8s`](https://hub.docker.com/r/basisai/consul-autoencrypt-k8s).

## Helm Chart

The "official" way to install this deployment is via the Helm Chart.

Note: Uninstalling the Helm chart will not clean up the `ConfigMap`s created. It is recommended
that you set `.Values.consul.configMaps.labels` with something unique and then you can discover all
the ConfigMaps to delete.

Using the default value

```bash
# List ConfigMaps
kubectl get configmaps -l app="consul-connect-ca" --all-namespaces

# Delete ConfigMaps
kubectl delete configmaps -l app="consul-connect-ca" --all-namespaces
```
