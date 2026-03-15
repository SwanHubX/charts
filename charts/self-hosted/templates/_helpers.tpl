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
Expand Deployment Selector Labels
These labels are used for spec.selector and Pod labels, and they are typically immutable.
*/}}
{{- define "swanlab.selectorLabels" -}}
app.kubernetes.io/provider: swanlab
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "swanlab.labels" -}}
{{ include "swanlab.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
helm.sh/chart: {{ include "swanlab.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Cluster domain
*/}}
{{- define "swanlab.clusterDomain" -}}
{{- default "cluster.local" .Values.global.clusterDomain -}}
{{- end }}

{{/*
Image pull secret
*/}}
{{- define "swanlab.imagePullSecrets" -}}
{{- toYaml .Values.global.imagePullSecrets -}}
{{- end }}


{{/*
Pod Distribution Constraints Configuration (Based on Topology Spread Constraints)

Usage: `{{ include "swanlab.podAntiAffinity" (list .Values.global.podAntiAffinityPreset "swanlab.component.selectorLabels" .) }}`
*/}}
{{- define "swanlab.podAntiAffinity" -}}
{{ $preset := index . 0 }}
{{ $selectorLabels := index . 1 }}
{{ $ctx := index . 2 }}
{{- if or (eq $preset "soft") (eq $preset "hard") }}
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: "kubernetes.io/hostname"
    {{- /* 软策略: 尽量分散 (ScheduleAnyway) */ -}}
    {{- if eq $preset "soft" }}
    whenUnsatisfiable: ScheduleAnyway
    {{- end }}
    {{- /* 硬策略: 强制分散 (DoNotSchedule) */ -}}
    {{- if eq $preset "hard" }}
    whenUnsatisfiable: DoNotSchedule
    {{- end }}
    labelSelector:
      matchLabels:
        {{- include $selectorLabels $ctx | nindent 8 }}
{{- end }}
{{- end }}