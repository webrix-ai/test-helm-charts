{{- define "hlmfk-0-0-7dfd7dcbdd.valuesYaml" -}}
{{- $runtime_app_tag := include "hlmfk-0-0.getValue" (dict "Values" .Values "path" (list "appVersion") "default" "latest") -}}
{{- $runtime_replicas := include "hlmfk-0-0.getValue" (dict "Values" .Values "path" (list "replicas") "default" "1") -}}
{{- $runtime_namespace := include "hlmfk-0-0.getValue" (dict "Values" .Values "path" (list "namespace") "default" "mcp-s") -}}
{{- $anchor_namespace_default := printf `mcp-s` -}}
{{- $anchor_replicas_default := printf `1` -}}
{{- $anchor_app_tag_default := printf `latest` -}}
{{- $final_namespace := include "hlmfk-0-0.pickFirstNonEmpty" (list $runtime_namespace $anchor_namespace_default) -}}
{{- $final_replicas := include "hlmfk-0-0.pickFirstNonEmpty" (list $runtime_replicas $anchor_replicas_default) -}}
{{- $final_app_tag := include "hlmfk-0-0.pickFirstNonEmpty" (list $runtime_app_tag $anchor_app_tag_default) -}}
{{- $result := printf `# globals:
#  namespace: "namespace"
#  namePrefix: "namePrefix"
#  nameSuffix: "nameSuffix"
#  nameReleasePrefix: "nameReleasePrefix"
#  labels:
#    key: "label"
#  annotations:
#    key: "annotation"
#  images:
#    - image: "old-image"
#      newName: "new-image"
#      newTag: "new-tag"
#      digest: "digest"
#      pullSecrets:
#        - name: "pull-secret"
#  resources:
#    - name: "resource"
#      version: "v1"
#      kind: "Resource"
overlay: "overlays/on-prem"
namespace: &namespace %v
replicas: &replicas %v
appVersion: &app_tag %v
globals:
  addStandardHeaders: false
  images:
    - image: quay.io/idan-chetrit/mcp-s-connect
      newTag: *app_tag
  namespace: *namespace
  patches:
    - target:
        kind: Deployment
        name: mcp-s-connect
      ops:
        - op: add
          path: /spec/replicas
          value: *replicas
env:
  AUTH_SECRET: aUi2V5iCVqUrbrdjKty1zH4HCqszXArV9BLVU2giqhY=
  DB_AUTH_SECRET: ZI39UlR2sN6HFZauuze0iNEZnNkF1wiOuGklm3bC8dk=
  DB_BASE_URL: http://mcp-s-db-service
  NEXTAUTH_URL: https://connect2.mcp-s.com
  PORT: "3000"
  AUTO_AUTHENTICATE_TOKEN: balQgAqCpKW979XoibTYSbfCjvj7uSJK+90m0iQG5
  RUN_URL: https://run2.mcp-s.com
  ON_PREM: "true"
  ORG: on-prem-org
  DEBUG: "true"
` $final_namespace $final_replicas $final_app_tag -}}
{{- $result -}}
{{- end -}}