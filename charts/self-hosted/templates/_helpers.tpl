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
Generates a securityContext block for the pod spec based on the owning service's settings.

Usage: {{- include "swanlab.podSecurityContext" (dict "root" . "securityContext" .Values.service.server.securityContext "uid" 1000 "gid" 1000) | nindent 6 }}
The uid and gid are used when the owning service's securityContext.enabled is true.
*/}}
{{- define "swanlab.podSecurityContext" -}}
{{- $sc := .securityContext | default (dict "enabled" false) -}}
{{- if $sc.enabled }}
securityContext:
  runAsNonRoot: true
  runAsUser: {{ .uid | int }}
  runAsGroup: {{ .gid | int }}
  fsGroup: {{ .gid | int }}
  fsGroupChangePolicy: OnRootMismatch
  seccompProfile:
    type: RuntimeDefault
  {{- /* 容器需监听 <1024 特权端口时（如 traefik/nginx 的 80），降低本 pod 网络命名空间的
       非特权端口起始值，使非 root 进程可直接绑定。相比 NET_BIND_SERVICE capability
       更可靠：capability 在 containerd 运行时下经 shell entrypoint exec 后会丢失，
       而 sysctl 是内核级检查，与运行时无关。要求节点内核 >= 4.11。 */ -}}
  {{- if .allowPrivilegedPorts }}
  sysctls:
    - name: net.ipv4.ip_unprivileged_port_start
      value: "80"
  {{- end }}
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
{{- $sc := .securityContext | default (dict "enabled" false) -}}
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
Root initContainer that aligns data-volume ownership with the service user before
startup. Rendered automatically when the owning service enables securityContext.
Needed for volumes whose files are owned by root (e.g. data written before
hardening), or clusters whose CSI fsGroupPolicy makes fsGroup ineffective.
Incompatible with the restricted PodSecurityStandard (root initContainer).

Usage:
  {{- with (include "swanlab.volumePermissionsInit" (dict "root" . "sc" .Values.dependencies.redis.securityContext "uid" 1000 "gid" 1000 "volumeName" "<volume-name>" "mountPath" "/data") | trim) }}
  initContainers:
    {{- . | nindent 8 }}
  {{- end }}
*/}}
{{- define "swanlab.volumePermissionsInit" -}}
{{- $sc := .sc | default (dict "enabled" false) -}}
{{- if $sc.enabled -}}
- name: init-volume-permissions
  image: {{ include "swanlab.helperImage" .root }}
  imagePullPolicy: {{ include "swanlab.helperPullPolicy" .root }}
  command: ["/bin/sh", "-c"]
  args:
    - |
      find {{ .mountPath }} ! -user {{ .uid }} -exec chown -R {{ .uid }}:{{ .gid }} {} \;
  securityContext:
    runAsUser: 0
    runAsNonRoot: false
    allowPrivilegeEscalation: false
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
        - ALL
      add:
        - CHOWN
        - DAC_OVERRIDE
  volumeMounts:
    - name: {{ .volumeName }}
      mountPath: {{ .mountPath }}
{{- end -}}
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
