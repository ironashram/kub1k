{{- define "letsencrypt.email" -}}
postmaster@{{ .Values.externalDomain }}
{{- end -}}

{{- define "letsencrypt.groupName" -}}
acme.{{ .Values.externalDomain }}
{{- end -}}

{{- define "letsencrypt.zoneName" -}}
{{ .Values.externalDomain }}
{{- end -}}
