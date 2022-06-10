# =============================================================================
# Make variables
# =============================================================================
NAMESPACE=todos
SERVICE_MESH_CONTROL_PLANE_NAMESPACE=istio-system
RELEASE=v1
GATEWAY_URL=todos.apps-crc.testing
# =============================================================================
# Install targets
# =============================================================================
install: install-sm install-app

install-app:
	@helm install --namespace $(NAMESPACE) \
		--set istio.enabled=true \
		--set istio.gateway.enabled=true \
		--set istio.gateway.hosts={"todos.apps-crc.testing"} \
		todos-$(RELEASE) src/todos-app

install-sm:
	@helm install --namespace $(NAMESPACE) \
		--set istio.gateway.name=todos-gateway \
		--set istio.gateway.namespace=$(NAMESPACE) \
		--set istio.gateway.hosts={"$(GATEWAY_URL)"} \
		--set istio.gateway.tls.enabled=true \
		--set istio.gateway.tls.credentialName=gateway-certs \
		--set istio.gateway.tls.httpsRedirect=true \
		--set route.enabled=true \
		--set route.name=todos-gateway-route \
		--set route.namespace=$(SERVICE_MESH_CONTROL_PLANE_NAMESPACE) \
		--set route.host="$(GATEWAY_URL)" \
		--set route.targetPort=https \
		--set route.tls.termination=passthrough \
		--set route.tls.insecurePolicy=Redirect \
		service-mesh-$(RELEASE) src/service-mesh
# =============================================================================
# Uninstall targets
# =============================================================================
uninstall: uninstall-app uninstall-sm

uninstall-app:
	@helm uninstall --namespace $(NAMESPACE) todos-$(RELEASE)

uninstall-sm:
	@helm uninstall --namespace $(NAMESPACE) service-mesh-$(RELEASE)
