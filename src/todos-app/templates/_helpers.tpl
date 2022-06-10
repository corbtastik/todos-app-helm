{{/* Name of composite chart for todos apps */}}
{{- define "todos.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Name of the todos service account to use */}}
{{- define "todos.serviceAccountName" -}}
{{- .Values.todos.serviceAccount.name }}
{{- end }}

{{/* Name of todos system. */}}
{{- define "todos.name" -}}
{{- .Values.system | trunc 63 }}
{{- end }}

{{/* All labels for todos apps, includes selector labels */}}
{{- define "todos.labels" -}}
helm.sh/chart: {{ include "todos.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "todos.selectorLabels" . }}
{{- end }}

{{/* Selector labels for todos apps, long and short app & version labels */}}
{{- define "todos.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "todos.name" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app: {{ include "todos.name" . }}
version: {{ .Chart.AppVersion }}
{{- end }}

{{/* Name of todos-webui deployment. */}}
{{- define "todos.webui.name" -}}
{{- .Values.todos.webui.name | trunc 63 }}
{{- end }}

{{/* All labels for todos-webui, includes selector labels */}}
{{- define "todos.webui.labels" -}}
helm.sh/chart: {{ include "todos.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "todos.webui.selectorLabels" . }}
{{- end }}

{{/* Selector labels for todos-webui, long and short app & version labels */}}
{{- define "todos.webui.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "todos.webui.name" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app: {{ include "todos.webui.name" . }}
version: {{ .Chart.AppVersion }}
{{- end }}

{{/* Name of todos-mysql deployment. */}}
{{- define "todos.mysql.name" -}}
{{- .Values.todos.mysql.name | trunc 63 }}
{{- end }}

{{/* All labels for todos-mysql, includes selector labels */}}
{{- define "todos.mysql.labels" -}}
helm.sh/chart: {{ include "todos.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "todos.mysql.selectorLabels" . }}
{{- end }}

{{/* Selector labels for todos-mysql, long and short app & version labels */}}
{{- define "todos.mysql.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "todos.mysql.name" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app: {{ include "todos.mysql.name" . }}
version: {{ .Chart.AppVersion }}
{{- end }}

{{/* Name of todos-db deployment. */}}
{{- define "todos.db.name" -}}
{{- .Values.todos.db.name | trunc 63 }}
{{- end }}

{{/* All labels for todos-db, includes selector labels */}}
{{- define "todos.db.labels" -}}
helm.sh/chart: {{ include "todos.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "todos.db.selectorLabels" . }}
{{- end }}

{{/* Selector labels for todos-db, long and short app & version labels */}}
{{- define "todos.db.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "todos.db.name" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app: {{ include "todos.db.name" . }}
version: {{ .Chart.AppVersion }}
{{- end }}