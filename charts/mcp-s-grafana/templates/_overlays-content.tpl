{{- define "hlmfk-1-2-5d80547625.yamls" }}
{{- if .Values.overlay }}
{{- if eq .Values.overlay "overlays/on-prem" }}
manifests:
  - spec: 
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: on-prem-mcp-s-grafana-container-vars-6ct58987ht
        namespace: webrix-mcp-s
  - spec: 
      apiVersion: v1
      kind: Service
      metadata:
        name: on-prem-mcp-s-grafana
        namespace: webrix-mcp-s
      spec:
        ports:
        - port: 8000
          protocol: TCP
          targetPort: 8000
        selector:
          app: mcp-s-grafana
  - spec: 
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        labels:
          app: mcp-s-grafana
        name: on-prem-mcp-s-grafana
        namespace: webrix-mcp-s
      spec:
        replicas: 1
        selector:
          matchLabels:
            app: mcp-s-grafana
        template:
          metadata:
            labels:
              app: mcp-s-grafana
          spec:
            containers:
            - envFrom:
              - configMapRef:
                  name: on-prem-mcp-s-grafana-container-vars-6ct58987ht
              image: mcp/grafana:latest
              name: mcp-s-grafana
              ports:
              - containerPort: 8000
              resources:
                limits:
                  cpu: 500m
                  memory: 512Mi
                requests:
                  cpu: 100m
                  memory: 128Mi
{{- else}}
{{- end }}
{{- else }}
manifests: []
{{- end }}{{- end }}