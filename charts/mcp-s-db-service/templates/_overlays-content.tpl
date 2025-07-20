{{- define "hlmfk-1-2-7b59532831.yamls" }}
{{- if .Values.overlay }}
{{- if eq .Values.overlay "overlays/on-prem" }}
manifests:
  - spec: 
      apiVersion: v1
      data:
        AUTH_SECRET: {{ .Values.env.AUTH_SECRET | quote }}
        AUTO_AUTHENTICATE_TOKEN: {{ .Values.env.AUTO_AUTHENTICATE_TOKEN | quote }}
        CONNECT_URL: {{ .Values.env.CONNECT_URL | quote }}
        DATABASE_URL: {{ .Values.env.DATABASE_URL | quote }}
        DEBUG_QUERIES: {{ .Values.env.DEBUG_QUERIES | quote }}
        ENCRYPTION_KEY: {{ .Values.env.ENCRYPTION_KEY | quote }}
        ON_PREM: {{ .Values.env.ON_PREM | quote }}
        ORG: {{ .Values.env.ORG | quote }}
        PORT: {{ .Values.env.PORT | quote }}
        POSTGRES_HOST_AUTH_METHOD: {{ .Values.env.POSTGRES_HOST_AUTH_METHOD | quote }}
        RATE_LIMIT_MAX: {{ .Values.env.RATE_LIMIT_MAX | quote }}
        RATE_LIMIT_WINDOW: {{ .Values.env.RATE_LIMIT_WINDOW | quote }}
        RUN_URL: {{ .Values.env.RUN_URL | quote }}
      kind: ConfigMap
      metadata:
        labels:
          app: mcp-s-db-service
          app.kubernetes.io/version: ""
        name: mcp-s-db-service-container-vars
        namespace: webrix
  - spec: 
      apiVersion: v1
      kind: ConfigMap
      metadata:
        labels:
          app: mcp-s-db-service
          app.kubernetes.io/version: ""
        name: mcp-s-db-service-environment-values
        namespace: webrix
  - spec: 
      apiVersion: v1
      kind: Service
      metadata:
        labels:
          app: mcp-s-db-service
          app.kubernetes.io/version: ""
        name: mcp-s-db-service
        namespace: webrix
      spec:
        ports:
        - port: 80
          protocol: TCP
          targetPort: 3000
        selector:
          app: mcp-s-db-service
  - spec: 
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        labels:
          app: mcp-s-db-service
          app.kubernetes.io/version: ""
        name: mcp-s-db-service
        namespace: webrix
      spec:
        replicas: 1
        selector:
          matchLabels:
            app: mcp-s-db-service
        template:
          metadata:
            labels:
              app: mcp-s-db-service
          spec:
            containers:
            - envFrom:
              - configMapRef:
                  name: mcp-s-db-service-container-vars
              image: quay.io/idan-chetrit/mcp-s-db-service:latest
              name: mcp-s-db-service
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