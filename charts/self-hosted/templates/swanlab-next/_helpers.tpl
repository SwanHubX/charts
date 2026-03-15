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
{{- $tag := .Values.service.next.image.tag | toString -}}
{{- if empty $tag -}}
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
SwanLab-Next Deployment / Service annotations (metadata.annotations)
*/}}
{{- define "swanlab.next.annotations" -}}
{{- if .Values.service.next.customAnnotations }}
{{- toYaml .Values.service.next.customAnnotations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Next Pod extra labels (template.metadata.labels)
*/}}
{{- define "swanlab.next.podLabels" -}}
{{- if .Values.service.next.customPodLabels }}
{{- toYaml .Values.service.next.customPodLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Next Pod annotations (template.metadata.annotations)
*/}}
{{- define "swanlab.next.podAnnotations" -}}
{{- if .Values.service.next.customPodAnnotations }}
{{- toYaml .Values.service.next.customPodAnnotations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Next Tolerations
*/}}
{{- define "swanlab.next.tolerations" -}}
{{- if .Values.service.next.customTolerations }}
{{- toYaml .Values.service.next.customTolerations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Next NodeSelector
*/}}
{{- define "swanlab.next.nodeSelector" -}}
{{- if .Values.service.next.customNodeSelector }}
{{- toYaml .Values.service.next.customNodeSelector }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Next Port
*/}}
{{- define "swanlab.next.port" -}}
{{- 80 -}}
{{- end -}}
