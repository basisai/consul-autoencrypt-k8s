{{/*
Expand the name of the chart.
*/}}
{{- define "consul-autoencrypt-k8s.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "consul-autoencrypt-k8s.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "consul-autoencrypt-k8s.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "consul-autoencrypt-k8s.labels" -}}
helm.sh/chart: {{ include "consul-autoencrypt-k8s.chart" . }}
{{ include "consul-autoencrypt-k8s.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "consul-autoencrypt-k8s.selectorLabels" -}}
app.kubernetes.io/name: {{ include "consul-autoencrypt-k8s.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "consul-autoencrypt-k8s.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "consul-autoencrypt-k8s.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "creation_test" }}
#!/bin/sh

success="false"
n=0
until [ "$n" -ge 5 ]
do
  echo "Checking namespaces..." \
    {{- range .Values.consul.configMaps.namespaces }}
    && echo "Checking {{ . }}..." \
    && kubectl -n {{ . | quote }} get configmap {{ $.Values.consul.configMaps.name | quote }} > /dev/null \
    {{- end }}
    && echo "All created" \
    && success="true" \
    && break

  echo "Not created. Waiting..."
  n=$((n+1))
  sleep 15
done

if [ "$success" = "false" ]; then
  echo "Failed"
  exit 1
fi

echo "Done"
{{- end }}
