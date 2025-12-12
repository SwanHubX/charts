{{/*
SwanLab-ServerFullname
Cut of 40 chars to comply with k8s name limit.
*/}}
{{- define "swanlab.server.fullname" -}}
{{- if .Values.service.server.fullnameOverride -}}
{{- .Values.service.server.fullnameOverride | trunc 40 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-server" (include "swanlab.fullname" .) | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
SwanLab-ServerImage
*/}}
{{- define "swanlab.server.image" -}}
{{- $defaultTag := printf "v%s" .Chart.AppVersion }}
{{- $tag := default $defaultTag .Values.service.server.image.tag }}
{{- printf "%s:%s" .Values.service.server.image.repository $tag -}}
{{- end -}}

{{/*
SwanLab-ServerCommon labels
*/}}
{{- define "swanlab.server.labels" -}}
{{ include "swanlab.labels" . }}
app.kubernetes.io/component: server
{{- if .Values.service.server.customLabels }}
{{ toYaml .Values.service.server.customLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-ServerSelector labels
*/}}
{{- define "swanlab.server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "swanlab.name" . }}-server
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
SwanLab-Server Port
*/}}
{{- define "swanlab.server.port" -}}
{{- 3000 -}}
{{- end -}}

{{/*
SwanLab-Server Identify URL
*/}}
{{- define "swanlab.server.identify" }}
{{- printf "http://%s:%s/api/identity" (include "swanlab.server.fullname" .) (include "swanlab.server.port" .) -}}
{{- end -}}