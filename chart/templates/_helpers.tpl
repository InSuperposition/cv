{{- define "cv.labels" -}}
app.kubernetes.io/name: cv
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "cv.selectorLabels" -}}
app.kubernetes.io/name: cv
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
