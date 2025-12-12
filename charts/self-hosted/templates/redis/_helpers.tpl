{{/*
Redis Fullname
Cut of 40 chars to comply with k8s name limit.
*/}}
{{- define "swanlab.redis.fullname" -}}
{{- if .Values.dependencies.redis.fullnameOverride -}}
{{- .Values.dependencies.redis.fullnameOverride | trunc 40 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-redis" (include "swanlab.fullname" .) | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Redis Selector labels
*/}}
{{- define "swanlab.redis.selectorLabels" -}}
{{ include "swanlab.selectorLabels" . }}
app.kubernetes.io/component: {{ include "swanlab.name" . }}-redis
{{- end -}}


{{/*
Redis Common labels
*/}}
{{- define "swanlab.redis.labels" -}}
{{ include "swanlab.redis.selectorLabels" . }}
app.kubernetes.io/service: redis
{{- if .Values.dependencies.redis.customLabels }}
{{ toYaml .Values.dependencies.redis.customLabels }}
{{- end }}
{{- end -}}

{{/*
Redis Secret Name
*/}}
{{- define "swanlab.redis.secretName" -}}
{{- if .Values.integrations.redis.enabled -}}
{{- required "If .Values.integrations.redis.enabled is true, you must specify the name of the existing secret via .Values.integrations.redis.existingSecret." .Values.integrations.redis.existingSecret -}}
{{- else -}}
{{ include "swanlab.redis.fullname" . }}-credentials
{{- end -}}
{{- end -}}

{{/*
Redis PVC Name
*/}}
{{- define "swanlab.redis.pvcName" -}}
{{.Values.dependencies.redis.persistence.existingClaim | default (printf "%s-pvc" (include "swanlab.redis.fullname" .)) }}
{{- end -}}