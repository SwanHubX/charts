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
{{- $tag := .Values.service.cloud.image.tag | toString -}}
{{- if empty $tag -}}
  {{- $tag = printf "v%s" (trimPrefix "v" .Chart.AppVersion) -}}
{{- end -}}
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
SwanLab-Cloud Deployment / Service annotations (metadata.annotations)
*/}}
{{- define "swanlab.cloud.annotations" -}}
{{- if .Values.service.cloud.customAnnotations }}
{{- toYaml .Values.service.cloud.customAnnotations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Cloud Pod extra labels (template.metadata.labels)
*/}}
{{- define "swanlab.cloud.podLabels" -}}
{{- if .Values.service.cloud.customPodLabels }}
{{- toYaml .Values.service.cloud.customPodLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Cloud Pod annotations (template.metadata.annotations)
*/}}
{{- define "swanlab.cloud.podAnnotations" -}}
{{- if .Values.service.cloud.customPodAnnotations }}
{{- toYaml .Values.service.cloud.customPodAnnotations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Cloud Tolerations
*/}}
{{- define "swanlab.cloud.tolerations" -}}
{{- if .Values.service.cloud.customTolerations }}
{{- toYaml .Values.service.cloud.customTolerations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Cloud NodeSelector
*/}}
{{- define "swanlab.cloud.nodeSelector" -}}
{{- if .Values.service.cloud.customNodeSelector }}
{{- toYaml .Values.service.cloud.customNodeSelector }}
{{- end }}
{{- end -}}


{{/*
SwanLab-Cloud Port
*/}}
{{- define "swanlab.cloud.port" -}}
{{- 80 -}}
{{- end -}}