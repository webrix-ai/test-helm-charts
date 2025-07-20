{{- define "hlmfk-1-2-5d80547625.valuesYaml" -}}
{{- $runtime_app_tag := include "hlmfk-1-2.getValue" (dict "Values" .Values "path" (list "appVersion") "default" "latest") -}}
{{- $runtime_replicas := include "hlmfk-1-2.getValue" (dict "Values" .Values "path" (list "replicas") "default" "1") -}}
{{- $runtime_namespace := include "hlmfk-1-2.getValue" (dict "Values" .Values "path" (list "namespace") "default" "mcp-s") -}}
{{- $anchor_namespace_default := printf `mcp-s` -}}
{{- $anchor_replicas_default := printf `1` -}}
{{- $anchor_app_tag_default := printf `latest` -}}
{{- $final_namespace := include "hlmfk-1-2.pickFirstNonEmpty" (list $runtime_namespace $anchor_namespace_default) -}}
{{- $final_replicas := include "hlmfk-1-2.pickFirstNonEmpty" (list $runtime_replicas $anchor_replicas_default) -}}
{{- $final_app_tag := include "hlmfk-1-2.pickFirstNonEmpty" (list $runtime_app_tag $anchor_app_tag_default) -}}
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
    - image: quay.io/idan-chetrit/mcp-s-grafana
      newTag: *app_tag
  namespace: *namespace
  patches:
    - target:
        kind: Deployment
        name: mcp-s-grafana
      ops:
        - op: add
          path: /spec/replicas
          value: *replicas
env:
  GRAFANA_URL: http://localhost:3000
  GRAFANA_API_KEY: ""
` $final_namespace $final_replicas $final_app_tag -}}
{{- $result -}}
{{- end -}}