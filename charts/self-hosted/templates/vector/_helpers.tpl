{{/*
Vector Fullname
Cut of 40 chars to comply with k8s name limit.
*/}}
{{- define "swanlab.vector.fullname" -}}
{{- if .Values.vector.fullnameOverride -}}
{{- .Values.vector.fullnameOverride | trunc 40 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-vector" (include "swanlab.fullname" .) | trunc 40 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Vector Selector labels
*/}}
{{- define "swanlab.vector.selectorLabels" -}}
{{ include "swanlab.selectorLabels" . }}
app.kubernetes.io/component: {{ include "swanlab.name" . }}-vector
{{- end -}}

{{/*
Vector Common labels
*/}}
{{- define "swanlab.vector.labels" -}}
{{ include "swanlab.vector.selectorLabels" . }}
app.kubernetes.io/service: vector
{{- if .Values.vector.customLabels }}
{{ toYaml .Values.vector.customLabels }}
{{- end }}
{{- end -}}

{{/*
Vector Deployment / Service annotations (metadata.annotations)
*/}}
{{- define "swanlab.vector.annotations" -}}
{{- if .Values.vector.customAnnotations }}
{{- toYaml .Values.vector.customAnnotations }}
{{- end }}
{{- end -}}

{{/*
Vector Pod extra labels (template.metadata.labels)
*/}}
{{- define "swanlab.vector.podLabels" -}}
{{- if .Values.vector.customPodLabels }}
{{- toYaml .Values.vector.customPodLabels }}
{{- end }}
{{- end -}}

{{/*
Vector Pod annotations (template.metadata.annotations)
*/}}
{{- define "swanlab.vector.podAnnotations" -}}
{{- if .Values.vector.customPodAnnotations }}
{{- toYaml .Values.vector.customPodAnnotations }}
{{- end }}
{{- end -}}

{{/*
Vector Tolerations
*/}}
{{- define "swanlab.vector.tolerations" -}}
{{- if .Values.vector.customTolerations }}
{{- toYaml .Values.vector.customTolerations }}
{{- end }}
{{- end -}}

{{/*
Vector NodeSelector
*/}}
{{- define "swanlab.vector.nodeSelector" -}}
{{- if .Values.vector.customNodeSelector }}
{{- toYaml .Values.vector.customNodeSelector }}
{{- end }}
{{- end -}}

{{/*
Vector ConfigMap name
*/}}
{{- define "swanlab.vector.configmap" -}}
{{- printf "%s-config" (include "swanlab.vector.fullname" .) -}}
{{- end -}}

{{/*
Vector http port (for dependency checks)
*/}}
{{- define "swanlab.vector.httpPort" -}}
8686
{{- end -}}

{{/*
Vector source port (for house -> vector data ingestion)
*/}}
{{- define "swanlab.vector.port" -}}
6000
{{- end -}}

{{/*
Vector metrics port (prometheus_exporter)
*/}}
{{- define "swanlab.vector.metricsPort" -}}
9090
{{- end -}}

{{/*
Vector host
*/}}
{{- define "swanlab.vector.host" -}}
{{ include "swanlab.vector.fullname" . }}
{{- end -}}
