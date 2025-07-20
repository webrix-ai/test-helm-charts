{{- define "hlmfk-1-2-bdc462df32.yamls" }}
{{- if .Values.overlay }}
{{- if eq .Values.overlay "overlays/on-prem" }}
manifests:
  - spec: 
      apiVersion: v1
      data:
        AUTH_SECRET: {{ .Values.env.AUTH_SECRET | quote }}
        BASE_URL: {{ .Values.env.BASE_URL | quote }}
        CONNECT_URL: {{ .Values.env.CONNECT_URL | quote }}
        DB_SERVICE_URL: {{ .Values.env.DB_SERVICE_URL | quote }}
        LOG_LEVEL: {{ .Values.env.LOG_LEVEL | quote }}
        ORG: {{ .Values.env.ORG | quote }}
        PORT: {{ .Values.env.PORT | quote }}
      kind: ConfigMap
      metadata:
        labels:
          app: mcp-s-run
          app.kubernetes.io/version: ""
        name: mcp-s-run-container-vars
        namespace: webrix
  - spec: 
      apiVersion: v1
      kind: ConfigMap
      metadata:
        labels:
          app: mcp-s-run
          app.kubernetes.io/version: ""
        name: mcp-s-run-environment-values
        namespace: webrix
  - spec: 
      apiVersion: v1
      kind: Service
      metadata:
        labels:
          app: mcp-s-run
          app.kubernetes.io/version: ""
        name: mcp-s-run
        namespace: webrix
      spec:
        ports:
        - port: 80
          protocol: TCP
          targetPort: 3000
        selector:
          app: mcp-s-run
  - spec: 
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        labels:
          app: mcp-s-run
          app.kubernetes.io/version: ""
        name: mcp-s-run
        namespace: webrix
      spec:
        replicas: 1
        selector:
          matchLabels:
            app: mcp-s-run
        template:
          metadata:
            labels:
              app: mcp-s-run
          spec:
            containers:
            - envFrom:
              - configMapRef:
                  name: mcp-s-run-container-vars
              image: quay.io/idan-chetrit/mcp-s-run:latest
              name: mcp-s-run
              ports:
              - containerPort: 3000
              resources:
                limits:
                  cpu: 1000m
                  memory: 2048Mi
                requests:
                  cpu: 100m
                  memory: 200Mi
{{- else}}
{{- end }}
{{- else }}
manifests: []
{{- end }}{{- end }}