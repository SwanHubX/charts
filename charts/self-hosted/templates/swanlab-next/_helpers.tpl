{{/*
SwanLab-Next Fullname
Cut of 40 chars to comply with k8s name limit.
*/}}
{{- define "swanlab.next.fullname" -}}
{{- if .Values.service.next.fullnameOverride -}}
{{- .Values.service.next.fullnameOverride | trunc 40 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-next" (include "swanlab.fullname" .) | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
SwanLab-Next Image
*/}}
{{- define "swanlab.next.image" -}}
{{- $tag := .Values.service.cloud.image.tag | toString -}}
{{- if not $tag -}}
  {{- $tag = printf "v%s" (trimPrefix "v" .Chart.AppVersion) -}}
{{- end -}}
{{- printf "%s:%s" .Values.service.next.image.repository $tag -}}
{{- end -}}


{{/*
SwanLab-Next Selector labels
*/}}
{{- define "swanlab.next.selectorLabels" -}}
{{ include "swanlab.selectorLabels" . }}
app.kubernetes.io/component: {{ include "swanlab.name" . }}-next
{{- end -}}

{{/*
SwanLab-Next Common labels
*/}}
{{- define "swanlab.next.labels" -}}
{{ include "swanlab.next.selectorLabels" . }}
app.kubernetes.io/service: next
{{- if .Values.service.next.customLabels }}
{{ toYaml .Values.service.next.customLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Next Port
*/}}
{{- define "swanlab.next.port" -}}
{{- 80 -}}
{{- end -}}
