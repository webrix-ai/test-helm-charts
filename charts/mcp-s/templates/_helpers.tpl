{{/*
Create a default fullname using release name and chart name
*/}}
{{- define "webrix.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else if .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "webrix.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Render an ingress block from a passed ingress definition
Usage:
{{ include "webrix.ingress" (dict "ingress" $ingress "context" $) }}
*/}}

{{- define "webrix.ingress" -}}
{{- $ := .context -}}
{{- $ingress := .ingress -}}
{{- if $ingress.enabled }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "webrix.fullname" $ }}-{{ $ingress.name }}
  namespace: {{ $ingress.namespace }}
  labels:
    {{- include "webrix.labels" $ | nindent 4 }}
  annotations:
    {{- range $key, $value := $ingress.annotations }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
spec:
  {{- if $ingress.className }}
  ingressClassName: {{ $ingress.className }}
  {{- end }}
  rules:
    {{- range $ingress.hosts }}
    - host: {{.subdomain }}{{ .host | default $.Values.host}}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ .backend }}
                port:
                  number: {{ .port | default 80 }}
          {{- end }}
    {{- end }}
  {{- if $ingress.tls }}
  tls:
    {{- range $ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}



{{- define "webrix.authurl" -}}
{{- if (lookup "v1" "Secret" .Release.Namespace (printf "%s-shared" (include "webrix.fullname" .))) -}}
{{ (lookup "v1" "Secret" .Release.Namespace (printf "%s-shared" (include "webrix.fullname" .))).data.password | b64dec }}
{{- else -}}
{{ randAlphaNum 32 }}
{{- end -}}
{{- end }}

{{/*
Return the database URL for dbservice
*/}}
{{- define "mcp-s.dbservice.db_url" -}}
{{- if eq .Values.global.db_provider "postgresql" -}}
postgresql://{{ .Values.dbservice.db.user }}:{{ .Values.dbservice.db.password }}@{{ .Release.Name }}-postgresql:{{ .Values.dbservice.db.port }}/{{ .Values.dbservice.db.name }}
{{- else if eq .Values.global.db_provider "external" -}}
{{- .Values.global.external_db_url -}}
{{- end -}}
{{- end -}}

{{/*
Override postgresql.enabled based on db_provider
*/}}
{{- define "mcp-s.postgresql.enabled" -}}
{{- if eq .Values.db_provider "postgresql" -}}
{{- true -}}
{{- else -}}
{{- false -}}
{{- end -}}
{{- end -}}
