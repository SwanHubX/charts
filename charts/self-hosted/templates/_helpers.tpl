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
Pod 级 securityContext，仅在所属服务 securityContext.enabled=true 时渲染。

Usage:
  {{- include "swanlab.podSecurityContext" (dict "root" . "securityContext" .Values.service.server.securityContext "uid" 1000 "gid" 1000) | nindent 6 }}

Params:
  root                 - 根上下文。
  securityContext      - 所属服务的 securityContext 配置。
  uid / gid            - 镜像内服务用户的 uid/gid。
  allowPrivilegedPorts - （可选）容器需以非 root 绑定特权端口（< 1024，
                         如 traefik/nginx 的 80）时置 true。
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
  {{- /* 安全 sysctl：允许非 root 进程绑定 >= 80 的端口。优于 NET_BIND_SERVICE
       capability（在 containerd 下经 shell entrypoint exec 后会丢失）。要求节点内核 >= 4.11。 */ -}}
  {{- if .allowPrivilegedPorts }}
  sysctls:
    - name: net.ipv4.ip_unprivileged_port_start
      value: "80"
  {{- end }}
{{- end }}
{{- end -}}

{{/*
容器级 securityContext，仅在所属服务 securityContext.enabled=true 时渲染。

Usage:
  {{- include "swanlab.containerSecurityContext" (dict "root" . "securityContext" .Values.service.server.securityContext) | nindent 10 }}
  {{- include "swanlab.containerSecurityContext" (dict "root" . "securityContext" .Values.gateway.securityContext "addCaps" (list "NET_BIND_SERVICE")) | nindent 10 }}

Params:
  root            - 根上下文。
  securityContext - 所属服务的 securityContext 配置。
  addCaps         - （可选）drop ALL 之后需要加回的 capability。
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
Root initContainer，在容器启动前将数据卷属主对齐为服务用户，仅在所属服务
securityContext.enabled=true 时渲染。覆盖两类场景：卷内残留 root 属主文件
（加固前写入），以及 CSI fsGroupPolicy 导致 fsGroup 失效的集群。因其以 root
运行，与 restricted PodSecurityStandard 不兼容，此类集群请保持
securityContext.enabled=false。

逐文件检查、仅 chown 不匹配项，卷已对齐时只付出一次只读遍历。不能用"检查卷
根目录属主"的短路替代：setgid 目录只把 group 遗传给新文件、不遗传 user，根
目录属主正常不代表卷内没有此前 root pod 写入的 root 属主文件。

Usage:
  {{- with (include "swanlab.volumePermissionsInit" (dict "root" . "securityContext" .Values.dependencies.redis.securityContext "uid" 1000 "gid" 1000 "volumeName" "<volume-name>" "mountPath" "/data") | trim) }}
  initContainers:
    {{- . | nindent 8 }}
  {{- end }}

Params:
  root            - 根上下文（helper 镜像 / 拉取策略）。
  securityContext - 所属服务的 securityContext 配置。
  uid / gid       - 服务用户的 uid/gid。
  volumeName      - 需要修正属主的数据卷。
  mountPath       - 数据卷在 initContainer 内的挂载路径。
*/}}
{{- define "swanlab.volumePermissionsInit" -}}
{{- $sc := .securityContext | default (dict "enabled" false) -}}
{{- if $sc.enabled -}}
- name: init-volume-permissions
  image: {{ include "swanlab.helperImage" .root }}
  imagePullPolicy: {{ include "swanlab.helperPullPolicy" .root }}
  command: ["/bin/sh", "-c"]
  args:
    - |
      find {{ .mountPath }} \( ! -user {{ .uid }} -o ! -group {{ .gid }} \) -exec chown {{ .uid }}:{{ .gid }} {} +
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
