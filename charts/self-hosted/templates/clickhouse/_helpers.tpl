{{/*
Clickhouse Fullname
Cut of 40 chars to comply with k8s name limit.
*/}}
{{- define "swanlab.clickhouse.fullname" -}}
{{- if .Values.dependencies.clickhouse.fullnameOverride -}}
{{- .Values.dependencies.clickhouse.fullnameOverride | trunc 40 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-clickhouse" (include "swanlab.fullname" .) | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Clickhouse Selector labels
*/}}
{{- define "swanlab.clickhouse.selectorLabels" -}}
{{ include "swanlab.selectorLabels" . }}
app.kubernetes.io/component: {{ include "swanlab.name" . }}-clickhouse
{{- end -}}

{{/*
Clickhouse Common labels
*/}}
{{- define "swanlab.clickhouse.labels" -}}
{{ include "swanlab.clickhouse.selectorLabels" . }}
app.kubernetes.io/service: clickhouse
{{- if .Values.dependencies.clickhouse.customLabels }}
{{ toYaml .Values.dependencies.clickhouse.customLabels }}
{{- end }}
{{- end -}}

{{/*
Clickhouse Secret Name
*/}}
{{- define "swanlab.clickhouse.secretName" -}}
{{- if .Values.integrations.clickhouse.enabled -}}
{{- required "If .Values.integrations.clickhouse.enabled is true, you must specify the name of the existing secret via .Values.integrations.clickhouse.existingSecret." .Values.integrations.clickhouse.existingSecret -}}
{{- else -}}
{{ include "swanlab.clickhouse.fullname" . }}-credentials
{{- end -}}
{{- end -}}


{{/*
Clickhouse PVC Name
*/}}
{{- define "swanlab.clickhouse.pvcName" -}}
{{ .Values.dependencies.clickhouse.persistence.existingClaim | default (printf "%s-pvc" (include "swanlab.clickhouse.fullname" .)) }}
{{- end -}}

{{/*
Clickhouse host
*/}}
{{- define "swanlab.clickhouse.host" -}}
{{- if .Values.integrations.clickhouse.enabled -}}
{{- required "If .Values.integrations.clickhouse.enabled is true, you must specify the host via .Values.integrations.clickhouse.host." .Values.integrations.clickhouse.host -}}
{{- else -}}
{{ include "swanlab.clickhouse.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Clickhouse http port
*/}}
{{- define "swanlab.clickhouse.httpPort" -}}
{{- if .Values.integrations.clickhouse.enabled -}}
{{- required "If .Values.integrations.clickhouse.enabled is true, you must specify the http port via .Values.integrations.clickhouse.httpPort." .Values.integrations.clickhouse.httpPort -}}
{{- else -}}
8123
{{- end -}}
{{- end -}}

{{/*
Clickhouse tcp port
*/}}
{{- define "swanlab.clickhouse.tcpPort" -}}
{{- if .Values.integrations.clickhouse.enabled -}}
{{- required "If .Values.integrations.clickhouse.enabled is true, you must specify the tcp port via .Values.integrations.clickhouse.tcpPort." .Values.integrations.clickhouse.tcpPort -}}
{{- else -}}
9000
{{- end -}}
{{- end -}}

{{/*
Clickhouse database
*/}}
{{- define "swanlab.clickhouse.database" -}}
{{- if .Values.integrations.clickhouse.enabled -}}
{{- required "If .Values.integrations.clickhouse.enabled is true, you must specify the database via .Values.integrations.clickhouse.database." .Values.integrations.clickhouse.database -}}
{{- else -}}
app
{{- end -}}
{{- end -}}
