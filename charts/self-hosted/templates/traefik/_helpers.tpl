{{/*
Traefik-Proxy fullname
*/}}
{{- define "swanlab.traefik.fullname" -}}
{{- printf "%s-traefik" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Traefik identity middleware name
*/}}
{{- define "swanlab.traefik.identify" -}}
{{- printf "%s-identity" (include "swanlab.traefik.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Traefik minio middleware name
*/}}
{{- define "swanlab.traefik.minio" -}}
{{- printf "%s-minio" (include "swanlab.traefik.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Traefik config map
*/}}
{{- define "swanlab.traefik.configmap" -}}
{{- printf "%s-traefik-config" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Generate a full FQDN with port for a Service.
Usage: {{ include "mychart.serviceAddress" (list $service $port $namespace $clusterDomain) }}
Parameters:
- service: The name of the Kubernetes Service.
- namespace: The namespace where the Service is located.
- clusterDomain: The cluster domain (e.g., "cluster.local").
- port: The port number to append.
*/}}
{{- define "swanlab.traefik.url"  -}}
{{- $service := index . 0 -}}
{{- $ns := index . 1 -}}
{{- $cluster := index . 2 -}}
{{- $port := index . 3 -}}
{{- /* Format Output: name.namespace.svc.clusterDomain:port */ -}}
{{- printf "http://%s.%s.svc.%s:%v" $service $ns $cluster $port -}}
{{- end -}}

{{/*
Helper function to generate the conditional Host() && PathPrefix() expression.
This is used internally by buildRouteBlock.
Params (list): [Host (string), Path (string)]
Usage: {{ include "swanlab.traefik.matchExpression" (list $host $path) }}
*/}}
{{- define "swanlab.traefik.match" -}}
{{- $host := index . 0 -}}
{{- $path := index . 1 -}}
{{- /* 1. Set the default matcher to PathPrefix */ -}}
{{- $matcher := "PathPrefix" -}}
{{- /* 2. Check if there is a third parameter; if it exists and is not empty, override the default value. */ -}}
{{- if and (gt (len .) 2) (index . 2) -}}
    {{- $matcher = index . 2 -}}
{{- end -}}
{{- /* 3. Generate rule string */ -}}
{{- if $host -}}
    {{- printf "Host(`%s`) && %s(`%s`)" $host $matcher $path -}}
{{- else -}}
    {{- printf "%s(`%s`)" $matcher $path -}}
{{- end -}}
{{- end -}}



{{/*
SwanLab-ServerCommon labels
*/}}
{{- define "swanlab.traefik.labels" -}}
{{ include "swanlab.labels" . }}
app.kubernetes.io/component: traefik
{{- if .Values.gateway.customLabels }}
{{ toYaml .Values.gateway.customLabels }}
{{- end }}
{{- end -}}

{{/*
SwanLab-ServerSelector labels
*/}}
{{- define "swanlab.traefik.selectorLabels" -}}
app.kubernetes.io/name: {{ include "swanlab.name" . }}-traefik
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}