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
{{- $tag := .Values.service.house.image.tag | toString -}}
{{- if empty $tag -}}
  {{- $tag = printf "v%s" (trimPrefix "v" .Chart.AppVersion) -}}
{{- end -}}
{{- printf "%s:%s" .Values.service.house.image.repository $tag -}}
{{- end -}}

{{/*
SwanLab-House Selector labels
*/}}
{{- define "swanlab.house.selectorLabels" -}}
{{ include "swanlab.selectorLabels" . }}
app.kubernetes.io/component: {{ include "swanlab.name" . }}-house
{{- end -}}

{{/*
SwanLab-House Common labels
*/}}
{{- define "swanlab.house.labels" -}}
{{ include "swanlab.house.selectorLabels" . }}
app.kubernetes.io/service: house
{{- if .Values.service.house.customLabels }}
{{ toYaml .Values.service.house.customLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-House Deployment / Service annotations (metadata.annotations)
*/}}
{{- define "swanlab.house.annotations" -}}
{{- if .Values.service.house.customAnnotations }}
{{- toYaml .Values.service.house.customAnnotations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-House Pod extra labels (template.metadata.labels)
*/}}
{{- define "swanlab.house.podLabels" -}}
{{- if .Values.service.house.customPodLabels }}
{{- toYaml .Values.service.house.customPodLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-House Pod annotations (template.metadata.annotations)
*/}}
{{- define "swanlab.house.podAnnotations" -}}
{{- if .Values.service.house.customPodAnnotations }}
{{- toYaml .Values.service.house.customPodAnnotations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-House Tolerations
*/}}
{{- define "swanlab.house.tolerations" -}}
{{- if .Values.service.house.customTolerations }}
{{- toYaml .Values.service.house.customTolerations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-House NodeSelector
*/}}
{{- define "swanlab.house.nodeSelector" -}}
{{- if .Values.service.house.customNodeSelector }}
{{- toYaml .Values.service.house.customNodeSelector }}
{{- end }}
{{- end -}}

{{/*
SwanLab-House Port
*/}}
{{- define "swanlab.house.port" -}}
{{- 3000 -}}
{{- end -}}
