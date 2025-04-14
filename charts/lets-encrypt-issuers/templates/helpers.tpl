{{- define "letsencrypt.email" -}}
postmaster@{{ .Values.domain }}
{{- end -}}

{{- define "letsencrypt.groupName" -}}
acme.{{ .Values.domain }}
{{- end -}}

{{- define "letsencrypt.zoneName" -}}
{{ .Values.domain }}
{{- end -}}
