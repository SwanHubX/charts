{{/*
SwanLab-Cloud Fullname
Cut of 40 chars to comply with k8s name limit.
*/}}
{{- define "swanlab.cloud.fullname" -}}
{{- if .Values.service.cloud.fullnameOverride -}}
{{- .Values.service.cloud.fullnameOverride | trunc 40 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-cloud" (include "swanlab.fullname" .) | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
SwanLab-Cloud Image
*/}}
{{- define "swanlab.cloud.image" -}}
{{- $tag := default .Values.service.cloud.image.tag .Chart.AppVersion }}
{{- printf "%s:v%s" .Values.service.cloud.image.repository $tag -}}
{{- end -}}

{{/*
SwanLab-Cloud Common labels
*/}}
{{- define "swanlab.cloud.labels" -}}
{{ include "swanlab.labels" . }}
app.kubernetes.io/component: cloud
{{- if .Values.service.cloud.customLabels }}
{{ toYaml .Values.service.cloud.customLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Cloud Selector labels
*/}}
{{- define "swanlab.cloud.selectorLabels" -}}
app.kubernetes.io/name: {{ include "swanlab.name" . }}-cloud
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/*
SwanLab-Cloud Port
*/}}
{{- define "swanlab.cloud.port" -}}
{{- 80 -}}
{{- end -}}