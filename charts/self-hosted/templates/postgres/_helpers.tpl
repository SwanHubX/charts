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
PostgreSQL Selector labels
*/}}
{{- define "swanlab.postgres.selectorLabels" -}}
{{ include "swanlab.selectorLabels" . }}
app.kubernetes.io/component: {{ include "swanlab.name" . }}-postgres
{{- end -}}

{{/*
PostgreSQL Common labels
*/}}
{{- define "swanlab.postgres.labels" -}}
{{ include "swanlab.postgres.selectorLabels" . }}
app.kubernetes.io/service: postgres
{{- if .Values.dependencies.postgres.customLabels }}
{{ toYaml .Values.dependencies.postgres.customLabels }}
{{- end }}
{{- end -}}

{{/*
PostgreSQL Deployment / Service annotations (metadata.annotations)
*/}}
{{- define "swanlab.postgres.annotations" -}}
{{- if .Values.dependencies.postgres.customAnnotations }}
{{- toYaml .Values.dependencies.postgres.customAnnotations }}
{{- end }}
{{- end -}}

{{/*
PostgreSQL Pod extra labels (template.metadata.labels)
*/}}
{{- define "swanlab.postgres.podLabels" -}}
{{- if .Values.dependencies.postgres.customPodLabels }}
{{- toYaml .Values.dependencies.postgres.customPodLabels }}
{{- end }}
{{- end -}}

{{/*
PostgreSQL Pod annotations (template.metadata.annotations)
*/}}
{{- define "swanlab.postgres.podAnnotations" -}}
{{- if .Values.dependencies.postgres.customPodAnnotations }}
{{- toYaml .Values.dependencies.postgres.customPodAnnotations }}
{{- end }}
{{- end -}}

{{/*
PostgreSQL Tolerations
*/}}
{{- define "swanlab.postgres.tolerations" -}}
{{- if .Values.dependencies.postgres.customTolerations }}
{{- toYaml .Values.dependencies.postgres.customTolerations }}
{{- end }}
{{- end -}}

{{/*
PostgreSQL NodeSelector
*/}}
{{- define "swanlab.postgres.nodeSelector" -}}
{{- if .Values.dependencies.postgres.customNodeSelector }}
{{- toYaml .Values.dependencies.postgres.customNodeSelector }}
{{- end }}
{{- end -}}

{{/*
PostgreSQL Secret Name
*/}}
{{- define "swanlab.postgres.secretName" -}}
{{- if .Values.integrations.postgres.enabled -}}
{{- required "If .Values.integrations.postgres.enabled is true, you must specify the name of the existing secret via .Values.integrations.postgres.existingSecret." .Values.integrations.postgres.existingSecret -}}
{{- else -}}
{{ include "swanlab.postgres.fullname" . }}-credentials
{{- end -}}
{{- end -}}


{{/*
PostgreSQL PVC Name
*/}}
{{- define "swanlab.postgres.pvcName" -}}
{{.Values.dependencies.postgres.persistence.existingClaim | default (printf "%s-pvc" (include "swanlab.postgres.fullname" .)) }}
{{- end -}}


{{/*
PostgreSQL host
*/}}
{{- define "swanlab.postgres.host" -}}
{{- if .Values.integrations.postgres.enabled -}}
{{- required "If .Values.integrations.postgres.enabled is true, you must specify the host via .Values.integrations.postgres.host." .Values.integrations.postgres.host -}}
{{- else -}}
{{ include "swanlab.postgres.fullname" . }}
{{- end -}}
{{- end -}}


{{/*
PostgreSQL port
*/}}
{{- define "swanlab.postgres.port" -}}
{{- if .Values.integrations.postgres.enabled -}}
{{- required "If .Values.integrations.postgres.enabled is true, you must specify the port via .Values.integrations.postgres.port." .Values.integrations.postgres.port -}}
{{- else -}}
{{ 5432 }}
{{- end -}}
{{- end -}}

{{/*
PostgreSQL database
*/}}
{{- define "swanlab.postgres.database" -}}
{{- if .Values.integrations.postgres.enabled -}}
{{- required "If .Values.integrations.postgres.enabled is true, you must specify the database via .Values.integrations.postgres.database." .Values.integrations.postgres.database -}}
{{- else -}}
{{ "app" }}
{{- end -}}
{{- end -}}

{{/*
PostgreSQL exporter prometheus metrics port (postgres-exporter 默认端口)
*/}}
{{- define "swanlab.postgres.metricsPort" -}}
9187
{{- end -}}

