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
S3 Selector labels
*/}}
{{- define "swanlab.s3.selectorLabels" -}}
{{ include "swanlab.selectorLabels" . }}
app.kubernetes.io/component: {{ include "swanlab.name" . }}-s3
{{- end -}}

{{/*
S3 Common labels
*/}}
{{- define "swanlab.s3.labels" -}}
{{ include "swanlab.s3.selectorLabels" . }}
app.kubernetes.io/service: s3
{{- if .Values.dependencies.s3.customLabels }}
{{ toYaml .Values.dependencies.s3.customLabels }}
{{- end }}
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
S3 Minio Port
*/}}
{{- define "swanlab.s3.minio.port" }}
{{- 9000 -}}
{{- end -}}


{{/*
S3 Private SSL
*/}}
{{- define "swanlab.s3.private.ssl" }}
{{- if .Values.integrations.s3.enabled -}}
{{- .Values.integrations.s3.private.ssl | default false -}}
{{- else -}}
{{- false -}}
{{- end -}}
{{- end -}}

{{/*
S3 Private Endpoint
*/}}
{{- define "swanlab.s3.private.endpoint" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 private endpoint via .Values.integrations.s3.private.endpoint." .Values.integrations.s3.private.endpoint -}}
{{- else -}}
{{- include "swanlab.s3.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
S3 Private Region
*/}}
{{- define "swanlab.s3.private.region" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 private region via .Values.integrations.s3.private.region." .Values.integrations.s3.private.region -}}
{{- else -}}
{{- "local" -}}
{{- end -}}
{{- end -}}

{{/*
S3 Private Port
 */}}
{{- define "swanlab.s3.private.port" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 private port via .Values.integrations.s3.private.port." .Values.integrations.s3.private.port -}}
{{- else -}}
{{- include "swanlab.s3.minio.port" . -}}
{{- end -}}
{{- end -}}

{{/*
S3 Private path style
*/}}
{{- define "swanlab.s3.private.pathStyle" }}
{{- if .Values.integrations.s3.enabled -}}
{{- .Values.integrations.s3.private.pathStyle | default false -}}
{{- else -}}
{{- true -}}
{{- end -}}
{{- end -}}


{{/*
S3 Private Bucket
*/}}
{{- define "swanlab.s3.private.bucket" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 private bucket via .Values.integrations.s3.private.bucket." .Values.integrations.s3.private.bucket -}}
{{- else -}}
{{- "swanlab-private" -}}
{{- end -}}
{{- end -}}


{{/*
S3 Public SSL
*/}}
{{- define "swanlab.s3.public.ssl" }}
{{- if .Values.integrations.s3.enabled -}}
{{- .Values.integrations.s3.public.ssl | default false -}}
{{- else -}}
{{- false -}}
{{- end -}}
{{- end -}}

{{/*
S3 Public Endpoint
*/}}
{{- define "swanlab.s3.public.endpoint" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 public endpoint via .Values.integrations.s3.public.endpoint." .Values.integrations.s3.public.endpoint -}}
{{- else -}}
{{- include "swanlab.s3.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
S3 Public Region
*/}}
{{- define "swanlab.s3.public.region" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 public region via .Values.integrations.s3.public.region." .Values.integrations.s3.public.region -}}
{{- else -}}
{{- "local" -}}
{{- end -}}
{{- end -}}

{{/*
S3 Public Port
 */}}
{{- define "swanlab.s3.public.port" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 public port via .Values.integrations.s3.public.port." .Values.integrations.s3.public.port -}}
{{- else -}}
{{- include "swanlab.s3.minio.port" . -}}
{{- end -}}
{{- end -}}

{{/*
S3 Public path style
*/}}
{{- define "swanlab.s3.public.pathStyle" }}
{{- if .Values.integrations.s3.enabled -}}
{{- .Values.integrations.s3.public.pathStyle | default false -}}
{{- else -}}
{{- true -}}
{{- end -}}
{{- end -}}


{{/*
S3 Public Bucket
*/}}
{{- define "swanlab.s3.public.bucket" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 public bucket via .Values.integrations.s3.public.bucket." .Values.integrations.s3.public.bucket -}}
{{- else -}}
{{- "swanlab-public" -}}
{{- end -}}
{{- end -}}



{{/*
S3 Public Domain
*/}}
{{- define "swanlab.s3.public.domain" }}
{{- if .Values.integrations.s3.enabled -}}
{{- required "If .Values.integrations.s3.enabled is true, you must specify the S3 public domain via .Values.integrations.s3.public.domain." .Values.integrations.s3.public.domain -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

