{{/* Labels every object gets */}}
{{- define "voting-app.labels" -}}
app.kubernetes.io/name: {{ .component }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/part-of: voting-app
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
helm.sh/chart: {{ .root.Chart.Name }}-{{ .root.Chart.Version }}
{{- end }}

{{/* Labels a Service uses to find its pods (must never change between releases) */}}
{{- define "voting-app.selectorLabels" -}}
app.kubernetes.io/name: {{ .component }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end }}

{{/* Full image reference for one of our app images, e.g. ghcr.io/jayprompts/voting-app-vote:<sha> */}}
{{- define "voting-app.image" -}}
{{ .root.Values.image.registry }}/{{ .repository }}:{{ required "image.tag is required (the pipeline sets it to the commit SHA)" .root.Values.image.tag }}
{{- end }}

{{/* Pod-level hardening: never run as root, use the runtime's default seccomp profile */}}
{{- define "voting-app.podSecurityContext" -}}
runAsNonRoot: true
seccompProfile:
  type: RuntimeDefault
{{- end }}

{{/* Container-level hardening: no privilege escalation, no Linux capabilities, read-only filesystem */}}
{{- define "voting-app.containerSecurityContext" -}}
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true
capabilities:
  drop: ["ALL"]
{{- end }}

{{/* Postgres connection settings for the apps, password read from the chart's Secret */}}
{{- define "voting-app.dbClientEnv" -}}
- name: PGHOST
  value: db
- name: PGUSER
  value: {{ .Values.db.auth.username | quote }}
- name: PGDATABASE
  value: {{ .Values.db.auth.database | quote }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-db
      key: password
{{- end }}

{{/* Rolling update that only removes an old pod once its replacement is ready,
     so a bad release never takes the running version down */}}
{{- define "voting-app.rollingUpdate" -}}
type: RollingUpdate
rollingUpdate:
  maxUnavailable: 0
  maxSurge: 1
{{- end }}
