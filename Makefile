# =============================================================================
# Make variables
# =============================================================================
NAMESPACE=todos
RELEASE=v1
GATEWAY_URL=todos.apps-crc.testing

install:
	@helm install --namespace $(NAMESPACE) \
		--set istio.enabled=true \
		--set istio.gateway.name=todos-gateway \
		--set istio.gateway.hosts={"$(GATEWAY_URL)"} \
		todos-$(RELEASE) src/todos-app

uninstall:
	@helm uninstall --namespace $(NAMESPACE) todos-$(RELEASE)
