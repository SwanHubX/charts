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
Helper Image
*/}}
{{- define "swanlab.helperImage" -}}
{{- $.Values.helper.image.repository }}:{{ $.Values.helper.image.tag }}
{{- end }}

{{/*
Helper Image Pull Policy
*/}}
{{- define "swanlab.helperPullPolicy" -}}
{{- $.Values.helper.image.pullPolicy }}
{{- end }}

{{/*
Pod-level security context.
Generates a securityContext block for the pod spec based on global.securityContext settings.

Usage: {{- include "swanlab.podSecurityContext" (dict "root" . "uid" 1000 "gid" 1000) | nindent 6 }}
The uid and gid are used as runAsUser/runAsGroup/fsGroup when global.securityContext.runAsNonRoot is true.
*/}}
{{- define "swanlab.podSecurityContext" -}}
{{- $sc := .root.Values.global.securityContext -}}
{{- if $sc.enabled }}
securityContext:
  {{- if $sc.runAsNonRoot }}
  runAsNonRoot: true
  runAsUser: {{ .uid | int }}
  runAsGroup: {{ .gid | int }}
  fsGroup: {{ .gid | int }}
  fsGroupChangePolicy: OnRootMismatch
  {{- end }}
  seccompProfile:
    type: RuntimeDefault
{{- end }}
{{- end -}}

{{/*
Container-level security context.
Generates a securityContext block for a container spec.

Usage (no extra capabilities):
  {{- include "swanlab.containerSecurityContext" (dict "root" .) | nindent 10 }}
Usage (with extra capabilities, e.g., NET_BIND_SERVICE for ports < 1024):
  {{- include "swanlab.containerSecurityContext" (dict "root" . "addCaps" (list "NET_BIND_SERVICE")) | nindent 10 }}
*/}}
{{- define "swanlab.containerSecurityContext" -}}
{{- $sc := .root.Values.global.securityContext -}}
{{- if $sc.enabled }}
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
    {{- if .addCaps }}
    add:
      {{- range .addCaps }}
      - {{ . }}
      {{- end }}
    {{- end }}
{{- end }}
{{- end -}}


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
