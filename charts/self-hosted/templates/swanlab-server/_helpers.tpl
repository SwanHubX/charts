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
SwanLab-Server Image
*/}}
{{- define "swanlab.server.image" -}}
{{- $tag := .Values.service.server.image.tag | toString -}}
{{- if empty $tag -}}
  {{- $tag = printf "v%s" (trimPrefix "v" .Chart.AppVersion) -}}
{{- end -}}
{{- printf "%s:%s" .Values.service.server.image.repository $tag -}}
{{- end -}}

{{/*
SwanLab-Server Selector labels
*/}}
{{- define "swanlab.server.selectorLabels" -}}
{{ include "swanlab.selectorLabels" . }}
app.kubernetes.io/component: {{ include "swanlab.name" . }}-server
{{- end -}}


{{/*
SwanLab-Server Common labels
*/}}
{{- define "swanlab.server.labels" -}}
{{ include "swanlab.server.selectorLabels" . }}
app.kubernetes.io/service: server
{{- if .Values.service.server.customLabels }}
{{ toYaml .Values.service.server.customLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Server Deployment / Service annotations (metadata.annotations)
*/}}
{{- define "swanlab.server.annotations" -}}
{{- if .Values.service.server.customAnnotations }}
{{- toYaml .Values.service.server.customAnnotations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Server Pod extra labels (template.metadata.labels)
*/}}
{{- define "swanlab.server.podLabels" -}}
{{- if .Values.service.server.customPodLabels }}
{{- toYaml .Values.service.server.customPodLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Server Pod annotations (template.metadata.annotations)
*/}}
{{- define "swanlab.server.podAnnotations" -}}
{{- if .Values.service.server.customPodAnnotations }}
{{- toYaml .Values.service.server.customPodAnnotations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Server Tolerations
*/}}
{{- define "swanlab.server.tolerations" -}}
{{- if .Values.service.server.customTolerations }}
{{- toYaml .Values.service.server.customTolerations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Server NodeSelector
*/}}
{{- define "swanlab.server.nodeSelector" -}}
{{- if .Values.service.server.customNodeSelector }}
{{- toYaml .Values.service.server.customNodeSelector }}
{{- end }}
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