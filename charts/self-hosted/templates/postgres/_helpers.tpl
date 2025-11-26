{{/*
PostgreSQL Fullname
Cut of 40 chars to comply with k8s name limit.
*/}}
{{- define "swanlab.postgres.fullname" -}}
{{- if .Values.dependencies.postgres.fullnameOverride -}}
{{- .Values.dependencies.postgres.fullnameOverride | trunc 40 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-postgres" (include "swanlab.fullname" .) | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
PostgreSQL Common labels
*/}}
{{- define "swanlab.postgres.labels" -}}
{{ include "swanlab.labels" . }}
app.kubernetes.io/component: postgres
{{- if .Values.dependencies.postgres.customLabels }}
{{ toYaml .Values.dependencies.postgres.customLabels }}
{{- end }}
{{- end -}}

{{/*
PostgreSQL Selector labels
*/}}
{{- define "swanlab.postgres.selectorLabels" -}}
app.kubernetes.io/name: {{ include "swanlab.name" . }}-postgres
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
PostgreSQL Secret Name
*/}}
{{- define "swanlab.postgres.secretName" -}}
{{ include "swanlab.postgres.fullname" . }}-credentials
{{- end -}}


{{/*
PostgreSQL PVC Name
*/}}
{{- define "swanlab.postgres.pvcName" -}}
{{.Values.dependencies.postgres.persistence.existingClaim | default (printf "%s-pvc" (include "swanlab.postgres.fullname" .)) }}
{{- end -}}