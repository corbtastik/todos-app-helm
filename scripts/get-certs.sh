#!/bin/bash

# The wildcard default serving certificate, created by the
# Ingress Operator and signed using the generated default CA certificate
#oc get secret router-certs-default \
#  -n openshift-ingress \
#  -o yaml > router-certs-default.yaml

mkdir -p .certs

oc get secret router-certs-default \
  -n openshift-ingress \
  -o json | jq -r '.data."tls.crt"' | base64 -d > .certs/tls.crt

oc get secret router-certs-default \
  -n openshift-ingress \
  -o json | jq -r '.data."tls.key"' | base64 -d > .certs/tls.key

# The contents of the wildcard default serving certificate
# (public and private parts) are copied here to enable OAuth integration
#oc get secret router-certs \
#  -n openshift-config-managed \
#  -o yaml > router-certs.yaml

# The public (certificate) part of the default serving certificate.
# Replaces the configmaps/router-ca resource
#
# This confimap - default-ingress-cert (public certificate)
# gets copied to namespace(s):
#   openshift-kube-controller-manager
#   openshift-kube-scheduler
#   openshift-console
oc get configmap default-ingress-cert \
  -n openshift-config-managed \
  -o json | jq -r '.data."ca-bundle.crt"' > .certs/ca-bundle.crt

oc create secret generic gateway-certs -n istio-system  \
  --from-file=key=.certs/tls.key \
  --from-file=cert=.certs/tls.crt \
  --from-file=cacert=.certs/ca-bundle.crt
