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
{{- $rawVersion := default .Chart.AppVersion .Values.service.cloud.image.tag | toString -}}
{{- $tag := printf "v%s" (trimPrefix "v" $rawVersion) -}}
{{- printf "%s:%s" .Values.service.cloud.image.repository $tag -}}
{{- end -}}


{{/*
SwanLab-Cloud Selector labels
*/}}
{{- define "swanlab.cloud.selectorLabels" -}}
{{ include "swanlab.selectorLabels" . }}
app.kubernetes.io/component: {{ include "swanlab.name" . }}-cloud
{{- end -}}

{{/*
SwanLab-Cloud Common labels
*/}}
{{- define "swanlab.cloud.labels" -}}
{{ include "swanlab.cloud.selectorLabels" . }}
app.kubernetes.io/service: cloud
{{- if .Values.service.cloud.customLabels }}
{{ toYaml .Values.service.cloud.customLabels }}
{{- end }}
{{- end -}}


{{/*
SwanLab-Cloud Port
*/}}
{{- define "swanlab.cloud.port" -}}
{{- 80 -}}
{{- end -}}