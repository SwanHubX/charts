{{/*
Expand the name of the chart.
*/}}
{{- define "traefik-proxy.name" -}}
{{- default .Chart.Name "" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "traefik-proxy.fullname" -}}
{{- $name := .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "traefik-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "traefik-proxy.labels" -}}
helm.sh/chart: {{ include "traefik-proxy.chart" . }}
app.kubernetes.io/version: {{ .Values.traefik.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Busybox image
*/}}
{{- define "traefik-proxy.busyboxImage" -}}
{{- $registry := default "" .Values.test.image.registry -}}
{{- $repository := default "busybox" .Values.test.image.repository -}}
{{- $tag := default "latest" .Values.test.image.tag -}}
{{- if $registry }}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end }}
{{- end }}
