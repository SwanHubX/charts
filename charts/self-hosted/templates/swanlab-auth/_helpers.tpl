{{/*
SwanLab-Auth Fullname
Cut of 40 chars to comply with k8s name limit.
*/}}
{{- define "swanlab.auth.fullname" -}}
{{- if .Values.service.auth.fullnameOverride -}}
{{- .Values.service.auth.fullnameOverride | trunc 40 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-auth" (include "swanlab.fullname" .) | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
SwanLab-Auth Identity URL (gateway identify plugin)
*/}}
{{- define "swanlab.auth.identify" -}}
{{- printf "http://%s:%s/api/auth/identity" (include "swanlab.auth.fullname" .) (include "swanlab.auth.port" .) -}}
{{- end -}}


{{/*
SwanLab-Auth Image
*/}}
{{- define "swanlab.auth.image" -}}
{{- $tag := .Values.service.auth.image.tag | toString -}}
{{- if empty $tag -}}
  {{- $tag = printf "v%s" (trimPrefix "v" .Chart.AppVersion) -}}
{{- end -}}
{{- printf "%s:%s" .Values.service.auth.image.repository $tag -}}
{{- end -}}


{{/*
SwanLab-Auth Selector labels
*/}}
{{- define "swanlab.auth.selectorLabels" -}}
{{ include "swanlab.selectorLabels" . }}
app.kubernetes.io/component: {{ include "swanlab.name" . }}-auth
{{- end -}}

{{/*
SwanLab-Auth Common labels
*/}}
{{- define "swanlab.auth.labels" -}}
{{ include "swanlab.auth.selectorLabels" . }}
app.kubernetes.io/service: auth
{{- if .Values.service.auth.customLabels }}
{{ toYaml .Values.service.auth.customLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Auth Deployment / Service annotations (metadata.annotations)
*/}}
{{- define "swanlab.auth.annotations" -}}
{{- if .Values.service.auth.customAnnotations }}
{{- toYaml .Values.service.auth.customAnnotations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Auth Pod extra labels (template.metadata.labels)
*/}}
{{- define "swanlab.auth.podLabels" -}}
{{- if .Values.service.auth.customPodLabels }}
{{- toYaml .Values.service.auth.customPodLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Auth Pod annotations (template.metadata.annotations)
*/}}
{{- define "swanlab.auth.podAnnotations" -}}
{{- if .Values.service.auth.customPodAnnotations }}
{{- toYaml .Values.service.auth.customPodAnnotations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Auth Tolerations
*/}}
{{- define "swanlab.auth.tolerations" -}}
{{- if .Values.service.auth.customTolerations }}
{{- toYaml .Values.service.auth.customTolerations }}
{{- end }}
{{- end -}}

{{/*
SwanLab-Auth NodeSelector
*/}}
{{- define "swanlab.auth.nodeSelector" -}}
{{- if .Values.service.auth.customNodeSelector }}
{{- toYaml .Values.service.auth.customNodeSelector }}
{{- end }}
{{- end -}}


{{/*
SwanLab-Auth Port
*/}}
{{- define "swanlab.auth.port" -}}
{{- 3000 -}}
{{- end -}}
