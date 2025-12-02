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