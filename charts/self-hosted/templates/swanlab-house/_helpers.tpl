{{/*
SwanLab-House Fullname
Cut of 40 chars to comply with k8s name limit.
*/}}
{{- define "swanlab.house.fullname" -}}
{{- if .Values.service.house.fullnameOverride -}}
{{- .Values.service.house.fullnameOverride | trunc 40 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-house" (include "swanlab.fullname" .) | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
SwanLab-House Image
*/}}
{{- define "swanlab.house.image" -}}
{{- $tag := default .Chart.AppVersion .Values.service.house.image.tag}}
{{- printf "%s:v%s" .Values.service.house.image.repository $tag -}}
{{- end -}}

{{/*
SwanLab-House Common labels
*/}}
{{- define "swanlab.house.labels" -}}
{{ include "swanlab.labels" . }}
app.kubernetes.io/component: house
{{- if .Values.service.house.customLabels }}
{{ toYaml .Values.service.house.customLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-House Selector labels
*/}}
{{- define "swanlab.house.selectorLabels" -}}
app.kubernetes.io/name: {{ include "swanlab.name" . }}-house
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
SwanLab-House Port
*/}}
{{- define "swanlab.house.port" -}}
{{- 3000 -}}
{{- end -}}
