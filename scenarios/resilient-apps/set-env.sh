cd ${HOME}/monolith

#ISTIO_VERSION=0.3.0
#ISTIO_HOME=${HOME}/istio-${ISTIO_VERSION}
#
## install istio
#cd ${HOME}
#curl -kL https://git.io/getLatestIstio | sed 's/curl/curl -k /g' | ISTIO_VERSION=${ISTIO_VERSION} sh -
#export PATH="$PATH:${ISTIO_HOME}/bin"
#cd ${ISTIO_HOME}
#oc adm policy add-scc-to-user anyuid -z istio-ingress-service-account -n istio-system
#oc adm policy add-scc-to-user anyuid -z default -n istio-system
#oc adm policy add-scc-to-user privileged -z default -n monolith
#oc apply -f install/kubernetes/istio.yaml
#oc adm policy add-cluster-role-to-user cluster-admin admin
#
## enable initializer auto sidecar injector
## oc apply -f install/kubernetes/istio-initializer.yaml
#
## install sample app
#oc new-project bookinfo
#oc adm policy add-scc-to-user privileged -z default -n bookinfo
#cd ${ISTIO_HOME}
#
#
#Fail 25%
#
#apiVersion: config.istio.io/v1alpha2
#kind: RouteRule
#metadata:
#  name: ratings-test-fail-25
#spec:
#  destination:
#    name: ratings
#  route:
#  - labels:
#      version: v1
#  httpFault:
#    abort:
#      percent: 25
#      httpStatus: 503
#
#Retry rule:
#
#apiVersion: config.istio.io/v1alpha2
#kind: RouteRule
#metadata:
#  name: ratings-test-retry
#spec:
#  destination:
#    name: ratings
#  match:
#    source: reviews
#  httpReqRetries:
#    simpleRetry:
#      attempts: 5
#      perTryTimeout: 2s
