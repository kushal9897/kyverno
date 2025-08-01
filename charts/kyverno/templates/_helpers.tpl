{{/* vim: set filetype=mustache: */}}

{{- define "kyverno.chartVersion" -}}
{{- if .Values.templating.enabled -}}
  {{- required "templating.version is required when templating.enabled is true" .Values.templating.version | replace "+" "_" -}}
{{- else -}}
  {{- .Chart.Version | replace "+" "_" -}}
{{- end -}}
{{- end -}}

{{- define "kyverno.features.flags" -}}
{{- $flags := list -}}
{{- with .admissionReports -}}
  {{- $flags = append $flags (print "--admissionReports=" .enabled) -}}
  {{- with .backPressureThreshold -}}
    {{- $flags = append $flags (print "--maxAdmissionReports=" .) -}}
  {{- end -}}
{{- end -}}
{{- with .aggregateReports -}}
  {{- $flags = append $flags (print "--aggregateReports=" .enabled) -}}
{{- end -}}
{{- with .policyReports -}}
  {{- $flags = append $flags (print "--policyReports=" .enabled) -}}
{{- end -}}
{{- with .validatingAdmissionPolicyReports -}}
  {{- $flags = append $flags (print "--validatingAdmissionPolicyReports=" .enabled) -}}
{{- end -}}
{{- with .mutatingAdmissionPolicyReports -}}
  {{- $flags = append $flags (print "--mutatingAdmissionPolicyReports=" .enabled) -}}
{{- end -}}
{{- with .autoUpdateWebhooks -}}
  {{- $flags = append $flags (print "--autoUpdateWebhooks=" .enabled) -}}
{{- end -}}
{{- with .backgroundScan -}}
  {{- $flags = append $flags (print "--backgroundScan=" .enabled) -}}
  {{- $flags = append $flags (print "--backgroundScanWorkers=" .backgroundScanWorkers) -}}
  {{- $flags = append $flags (print "--backgroundScanInterval=" .backgroundScanInterval) -}}
  {{- $flags = append $flags (print "--skipResourceFilters=" .skipResourceFilters) -}}
{{- end -}}
{{- with .configMapCaching -}}
  {{- $flags = append $flags (print "--enableConfigMapCaching=" .enabled) -}}
{{- end -}}
{{- with .controllerRuntimeMetrics -}}
  {{- $flags = append $flags (print "--controllerRuntimeMetricsAddress=" .bindAddress) -}}
{{- end -}}
{{- with .deferredLoading -}}
  {{- $flags = append $flags (print "--enableDeferredLoading=" .enabled) -}}
{{- end -}}
{{- with .dumpPayload -}}
  {{- $flags = append $flags (print "--dumpPayload=" .enabled) -}}
{{- end -}}
{{- with .forceFailurePolicyIgnore -}}
  {{- $flags = append $flags (print "--forceFailurePolicyIgnore=" .enabled) -}}
{{- end -}}
{{- with .generateValidatingAdmissionPolicy -}}
  {{- $flags = append $flags (print "--generateValidatingAdmissionPolicy=" .enabled) -}}
{{- end -}}
{{- with .generateMutatingAdmissionPolicy -}}
  {{- $flags = append $flags (print "--generateMutatingAdmissionPolicy=" .enabled) -}}
{{- end -}}
{{- with .dumpPatches -}}
  {{- $flags = append $flags (print "--dumpPatches=" .enabled) -}}
{{- end -}}
{{- with .globalContext -}}
  {{- $flags = append $flags (print "--maxAPICallResponseLength=" (int .maxApiCallResponseLength)) -}}
{{- end -}}
{{- with .logging -}}
  {{- $flags = append $flags (print "--loggingFormat=" .format) -}}
  {{- $flags = append $flags (print "--v=" (join "," .verbosity)) -}}
{{- end -}}
{{- with .omitEvents -}}
  {{- with .eventTypes -}}
    {{- $flags = append $flags (print "--omitEvents=" (join "," .)) -}}
  {{- end -}}
{{- end -}}
{{- with .policyExceptions -}}
  {{- $flags = append $flags (print "--enablePolicyException=" .enabled) -}}
  {{- with .namespace -}}
    {{- $flags = append $flags (print "--exceptionNamespace=" .) -}}
  {{- end -}}
{{- end -}}
{{- with .protectManagedResources -}}
  {{- $flags = append $flags (print "--protectManagedResources=" .enabled) -}}
{{- end -}}
{{- with .registryClient -}}
  {{- $flags = append $flags (print "--allowInsecureRegistry=" .allowInsecure) -}}
  {{- $flags = append $flags (print "--registryCredentialHelpers=" (join "," .credentialHelpers)) -}}
{{- end -}}
{{- with .ttlController -}}
  {{- $flags = append $flags (print "--ttlReconciliationInterval=" .reconciliationInterval) -}}
{{- end -}}
{{- with .tuf -}}
  {{- with .enabled -}}
    {{- $flags = append $flags (print "--enableTuf=" .) -}}
  {{- end -}}
  {{- with .mirror -}}
    {{- $flags = append $flags (print "--tufMirror=" .) -}}
  {{- end -}}
  {{- with .root -}}
    {{- $flags = append $flags (print "--tufRoot=" .) -}}
  {{- end -}}
  {{- with .rootRaw -}}
    {{- $flags = append $flags (print "--tufRootRaw=" .) -}}
  {{- end -}}
{{- end -}}
{{- with .reporting -}}
  {{- $reportingConfig := list -}}
  {{- with .validate -}}
    {{- $reportingConfig = append $reportingConfig "validate" -}}
  {{- end -}}
  {{- with .mutate -}}
    {{- $reportingConfig = append $reportingConfig "mutate" -}}
  {{- end -}}
  {{- with .mutateExisting -}}
    {{- $reportingConfig = append $reportingConfig "mutateExisting" -}}
  {{- end -}}
  {{- with .imageVerify -}}
    {{- $reportingConfig = append $reportingConfig "imageVerify" -}}
  {{- end -}}
  {{- with .generate -}}
    {{- $reportingConfig = append $reportingConfig "generate" -}}
  {{- end -}}
  {{- $flags = append $flags (print "--enableReporting=" (join "," $reportingConfig)) -}}
{{- end -}}
{{- with $flags -}}
  {{- toYaml . -}}
{{- end -}}
{{- end -}}

{{/* Helper function to sort imagePullSecrets by name to ensure consistent ordering */}}
{{- define "kyverno.sortedImagePullSecrets" -}}
{{- if . -}}
{{- $secrets := list -}}
{{- range . -}}
{{- $secrets = append $secrets .name -}}
{{- end -}}
{{- $sortedSecrets := list -}}
{{- if $secrets -}}
{{- $sortedSecrets = sortAlpha $secrets -}}
{{- end -}}
{{- $sortedRefs := list -}}
{{- range $sortedSecrets -}}
{{- $sortedRefs = append $sortedRefs (dict "name" .) -}}
{{- end -}}
{{- toYaml $sortedRefs -}}
{{- end -}}
{{- end -}}
