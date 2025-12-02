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
Clickhouse Common labels
*/}}
{{- define "swanlab.clickhouse.labels" -}}
{{ include "swanlab.labels" . }}
app.kubernetes.io/component: clickhouse
{{- if .Values.dependencies.clickhouse.customLabels }}
{{ toYaml .Values.dependencies.clickhouse.customLabels }}
{{- end }}
{{- end -}}

{{/*
Clickhouse Selector labels
*/}}
{{- define "swanlab.clickhouse.selectorLabels" -}}
app.kubernetes.io/name: {{ include "swanlab.name" . }}-clickhouse
app.kubernetes.io/instance: {{ .Release.Name }}
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


{{/*
Clickhouse PVC Name
*/}}
{{- define "swanlab.clickhouse.pvcName" -}}
{{ .Values.dependencies.clickhouse.persistence.existingClaim | default (printf "%s-pvc" (include "swanlab.clickhouse.fullname" .)) }}
{{- end -}}