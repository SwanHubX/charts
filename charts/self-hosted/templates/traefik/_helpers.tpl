{{/*
Traefik-Proxy fullname
*/}}
{{- define "swanlab.traefik.fullname" -}}
{{- printf "%s-traefik" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "swanlab.traefik.identify" -}}
{{- printf "%s-identity" (include "swanlab.traefik.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Parses labelSelector ("key=value") into a YAML label map.
Usage:
    {{ include "swanlab.traefik.crd.label" . }}
*/}}
{{- define "swanlab.traefik.crd.label" -}}
{{- $raw := .Values.ingress.traefik.providers.kubernetesCRD.labelSelector | quote -}}
{{- /* Convert to string, remove quotes */ -}}
{{- $raw = trimAll "\"" $raw -}}
{{- /* Split by "=" */ -}}
{{- $parts := splitList "=" $raw -}}
{{- if ne (len $parts) 2 }}
  {{- fail (printf "labelSelector must be 'key=value', got: %s" $raw) }}
{{- end }}
{{- $key := index $parts 0 | trim -}}
{{- $val := index $parts 1 | trim -}}
{{- /* Output YAML */ -}}
{{ printf "%s: %q" $key $val }}
{{- end -}}


{{/*
Returns the EntryPoint name based on whether TLS exists

Parameters: TLS Secret name (string) or empty

Example call: {{ include "swanlab.traefik.getEntryPoint" $tls }}
*/}}
{{- define "swanlab.traefik.entrypoint" -}}
{{- $tls := . -}}
{{- if $tls }}websecure{{ else }}web{{ end -}}
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