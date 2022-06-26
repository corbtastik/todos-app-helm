# =============================================================================
# Make variables
# =============================================================================
NAMESPACE=todos
RELEASE=v1
GATEWAY_URL=todos.apps-crc.testing
# =============================================================================
# helm targets
# =============================================================================
install:
	@helm install --namespace $(NAMESPACE) \
		--set istio.enabled=true \
		--set istio.gateway.name=todos-gateway \
		--set istio.gateway.hosts={"$(GATEWAY_URL)"} \
		todos-$(RELEASE) src/todos-app

uninstall:
	@helm uninstall --namespace $(NAMESPACE) todos-$(RELEASE)
# =============================================================================
# oc targets
# =============================================================================
apply:
	@oc apply -f src/manifests/todos-app/todos-app.yaml -n $(NAMESPACE)

delete:
	@oc delete -f src/manifests/todos-app/todos-app.yaml -n $(NAMESPACE)

apply-istio:
	@oc apply -f src/manifests/istio/todos-istio.yaml -n $(NAMESPACE)

delete-istio:
	@oc delete -f src/manifests/istio/todos-istio.yaml -n $(NAMESPACE)

apply-ingress:
	@oc apply -f src/manifests/ingress/todos-ingress.yaml -n $(NAMESPACE)

delete-ingress:
	@oc delete -f src/manifests/ingress/todos-ingress.yaml -n $(NAMESPACE)
