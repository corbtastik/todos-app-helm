# =============================================================================
# Make variables, override like so:
# $ make install APP_NAMESPACE=my-namespace RELEASE=v1
# =============================================================================
ADMIN_NAMESPACE=istio-system
APP_NAMESPACE=todos
CLUSTER_NAME=crc.testing
CLUSTER_REGION=local
GATEWAY_TLS_SECRET=gateway-certs
INGRESS_URL=todos.apps-crc.testing
RELEASE=v1
# =============================================================================
# Install/Uninstall targets for todos sample app
# =============================================================================
# Install using rendered manifests
install-manifests:
	@oc apply -f ./manifests/all.yaml -n $(APP_NAMESPACE)
	@oc apply -f ./manifests/ingress-route.yaml -n $(ADMIN_NAMESPACE)

# Install using openshift ingress networking (no istio service mesh)
install:
	@helm install --namespace $(APP_NAMESPACE) \
		--set cluster.name=$(CLUSTER_NAME) \
		--set cluster.region=$(CLUSTER_REGION) \
		--set istio.enabled=false \
		--set route.enabled=true \
		--set route.host="$(INGRESS_URL)" \
		todos-$(RELEASE) src/todos-app

template:
	@mkdir -p ./src/manifests/todos-$(RELEASE)
	@helm template --namespace $(APP_NAMESPACE) \
		--set cluster.name=$(CLUSTER_NAME) \
		--set cluster.region=$(CLUSTER_REGION) \
		--set istio.enabled=false \
		--set route.enabled=true \
		--set route.host="$(INGRESS_URL)" \
		todos-$(RELEASE) src/todos-app > src/manifests/todos-$(RELEASE)/todos-$(RELEASE).yaml

# Install using istio service mesh networking
install-istio:
	@helm install --namespace $(APP_NAMESPACE) \
		--set cluster.name=$(CLUSTER_NAME) \
		--set cluster.region=$(CLUSTER_REGION) \
		--set istio.enabled=true \
		--set istio.gateway.hosts={"$(INGRESS_URL)"} \
		todos-$(RELEASE) src/todos-app

# Install using istio service mesh networking with tls
install-istio-tls:
	@helm install --namespace $(APP_NAMESPACE) \
		--set cluster.name=$(CLUSTER_NAME) \
		--set cluster.region=$(CLUSTER_REGION) \
		--set istio.enabled=true \
		--set istio.gateway.hosts={"$(INGRESS_URL)"} \
		--set istio.gateway.tls.enabled=true \
		--set istio.gateway.tls.credentialName=$(GATEWAY_TLS_SECRET) \
		--set route.enabled=false \
		--set route.namespace=$(ADMIN_NAMESPACE) \
		--set route.host="$(INGRESS_URL)" \
		--set route.targetPort=https \
		todos-$(RELEASE) src/todos-app

uninstall:
	@helm uninstall --namespace $(APP_NAMESPACE) todos-$(RELEASE)
# =============================================================================
# Install/Uninstall targets for istio gateway TLS secret
# This uses OpenShift's default ingress certs to config tls on the gateway
# =============================================================================
install-certs:
	@mkdir -p .certs
	@oc get secret router-certs-default \
  		-n openshift-ingress \
  		-o json | jq -r '.data."tls.crt"' | base64 -d > .certs/tls.crt
	@oc get secret router-certs-default \
  		-n openshift-ingress \
  		-o json | jq -r '.data."tls.key"' | base64 -d > .certs/tls.key
	@oc get configmap default-ingress-cert \
	  -n openshift-config-managed \
	  -o json | jq -r '.data."ca-bundle.crt"' > .certs/ca-bundle.crt
	@oc create secret generic $(GATEWAY_TLS_SECRET) -n $(ADMIN_NAMESPACE)  \
  		--from-file=key=.certs/tls.key \
  		--from-file=cert=.certs/tls.crt \
  		--from-file=cacert=.certs/ca-bundle.crt
	@rm -r -f .certs

uninstall-certs:
	@oc delete secret $(GATEWAY_TLS_SECRET) -n $(ADMIN_NAMESPACE)

# =============================================================================
# Targets for working with the mysql todos-db database
# =============================================================================
insert: insert-records select-all

select-all:
	@oc exec -it -n $(APP_NAMESPACE) \
		`oc get pods --template "{{range .items}}{{.metadata.name}}{{end}}" --selector=app=todos-db -n $(APP_NAMESPACE)` \
		--container=todos-db -- /bin/bash -c \
		'mysql -uuser1 -pmysql123 -e "SELECT * FROM todos.todos;"'

delete-all:
	@oc exec -it -n $(APP_NAMESPACE) \
		`oc get pods --template "{{range .items}}{{.metadata.name}}{{end}}" --selector=app=todos-db -n $(APP_NAMESPACE)` \
		--container=todos-db -- /bin/bash -c \
		'mysql -uuser1 -pmysql123 -e "DELETE FROM todos.todos;"'

insert-records:
	@oc exec -it -n $(APP_NAMESPACE) \
		`oc get pods --template "{{range .items}}{{.metadata.name}}{{end}}" --selector=app=todos-db -n $(APP_NAMESPACE)` \
		--container=todos-db -- /bin/bash -c \
		'mysql -uuser1 -pmysql123 -e "INSERT INTO todos.todos(id, title, complete) VALUE (2000, \"Take out trash.\", FALSE);"'
	@oc exec -it -n $(APP_NAMESPACE) \
		`oc get pods --template "{{range .items}}{{.metadata.name}}{{end}}" --selector=app=todos-db -n $(APP_NAMESPACE)` \
		--container=todos-db -- /bin/bash -c \
		'mysql -uuser1 -pmysql123 -e "INSERT INTO todos.todos(id, title, complete) VALUE (2001, \"Walk the dog.\", FALSE);"'
	@oc exec -it -n $(APP_NAMESPACE) \
		`oc get pods --template "{{range .items}}{{.metadata.name}}{{end}}" --selector=app=todos-db -n $(APP_NAMESPACE)` \
		--container=todos-db -- /bin/bash -c \
		'mysql -uuser1 -pmysql123 -e "INSERT INTO todos.todos(id, title, complete) VALUE (2002, \"Take kids to school.\", FALSE);"'
