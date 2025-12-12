{{/*
Expand the name of the chart.
*/}}
{{- define "swanlab.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 40 chars because fullname will be used as a prefix for other components.
If release name contains chart name it will be used as a full name.
*/}}
{{- define "swanlab.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 40 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 40 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 40 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "swanlab.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "swanlab.labels" -}}
helm.sh/chart: {{ include "swanlab.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Cluster domain
*/}}
{{- define "swanlab.clusterDomain" -}}
{{- default "cluster.local" .Values.global.clusterDomain -}}
{{- end }}

{{/*
Image pull secrect
*/}}
{{- define "swanlab.imagePullSecrets" -}}
{{- toYaml .Values.global.imagePullSecrets -}}
{{- end }}
