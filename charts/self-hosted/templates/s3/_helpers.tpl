{{/*
S3 Fullname
Cut of 40 chars to comply with k8s name limit.
*/}}
{{- define "swanlab.s3.fullname" -}}
{{- if .Values.dependencies.s3.fullnameOverride -}}
{{- .Values.dependencies.s3.fullnameOverride | trunc 40 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-s3" (include "swanlab.fullname" .) | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
S3 Common labels
*/}}
{{- define "swanlab.s3.labels" -}}
{{ include "swanlab.labels" . }}
app.kubernetes.io/component: s3
{{- if .Values.dependencies.s3.customLabels }}
{{ toYaml .Values.dependencies.s3.customLabels }}
{{- end }}
{{- end -}}

{{/*
S3 Selector labels
*/}}
{{- define "swanlab.s3.selectorLabels" -}}
app.kubernetes.io/name: {{ include "swanlab.name" . }}-s3
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
S3 Secret Name
*/}}
{{- define "swanlab.s3.secretName" -}}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the name of the existing secret via .Values.integrations.s3.existingSecret." .Values.integrations.s3.existingSecret -}}
{{- else -}}
{{ include "swanlab.s3.fullname" . }}-credentials
{{- end -}}
{{- end -}}


{{/*
S3 PVC Name
*/}}
{{- define "swanlab.s3.pvcName" -}}
{{.Values.dependencies.s3.persistence.existingClaim | default (printf "%s-pvc" (include "swanlab.s3.fullname" .)) }}
{{- end -}}

{{/*
S3 Type
*/}}
{{- define "swanlab.s3.type" }}
{{- if .Values.integrations.s3.enabled -}}
{{- "remote" -}}
{{- else -}}
{{- "local" -}}
{{- end -}}
{{- end -}}


{{/*
S3 SSL
*/}}
{{- define "swanlab.s3.ssl" }}
{{- if .Values.integrations.s3.enabled -}}
{{- .Values.integrations.s3.ssl | default false -}}
{{- else -}}
{{- false -}}
{{- end -}}
{{- end -}}

{{/*
S3 Endpoint
*/}}
{{- define "swanlab.s3.endpoint" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 endpoint via .Values.integrations.s3.endpoint." .Values.integrations.s3.endpoint -}}
{{- else -}}
{{- include "swanlab.s3.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
S3 Port
*/}}
{{- define "swanlab.s3.port" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 port via .Values.integrations.s3.port." .Values.integrations.s3.port -}}
{{- else -}}
{{- 9000 -}}
{{- end -}}
{{- end -}}

{{/*
S3 Region
*/}}
{{- define "swanlab.s3.region" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 region via .Values.integrations.s3.region." .Values.integrations.s3.region -}}
{{- else -}}
{{- "local" -}}
{{- end -}}
{{- end -}}

{{/*
S3 Domain
*/}}
{{- define "swanlab.s3.domain" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 domain via .Values.integrations.s3.domain." .Values.integrations.s3.domain -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{/*
S3 Path Style
*/}}
{{- define "swanlab.s3.pathStyle" }}
{{- if .Values.integrations.s3.enabled -}}
{{- .Values.integrations.s3.pathStyle | default true -}}
{{- else -}}
{{- true -}}
{{- end -}}
{{- end -}}

