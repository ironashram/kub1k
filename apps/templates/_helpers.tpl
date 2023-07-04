{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 24 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 24 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "common.labels" -}}
app.kubernetes.io/name: {{ include "name" . }}
helm.sh/chart: {{ include "chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* Select Slack alert channel based on environment */}}
{{- define "alert_channel" -}}
{{- if eq .Values.environment "production" -}}
'#alerts-bedrock'
{{- else if eq .Values.environment "staging" -}}
'#alerts-bedrock-staging'
{{- else if eq .Values.environment "testing" -}}
'#alerts-bedrock-testing'
{{- else if eq .Values.environment "development" -}}
'#alerts-bedrock-development'
{{- end -}}
{{- end -}}

{{/* Select domain based on environment */}}
{{- define "domain" -}}
{{- if eq .Values.environment "production" -}}
lab.m1k.cloud
{{- else if eq .Values.environment "staging" -}}
namecheapcloud.host
{{- else if eq .Values.environment "testing" -}}
namecheapcloud.wtf
{{- else if eq .Values.environment "development" -}}
bedrock.tld
{{- end -}}
{{- end -}}

