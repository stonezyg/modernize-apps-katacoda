In this step, we'll install Istio into our OpenShift platform.

Run the following command:

`sh ~/install-istio.sh`{{execute}}

This command:

* Creates the project `istio-system` as the location to deploy all the components
* Adds necessary permissions
* Deploys Istio components
* Deploys additional add-ons, namely Prometheus, Grafana, Service Graph and Zipkin
* Exposes routes for those add-ons and for Istio's Ingress component

We'll use the above components througout this scenario, so don't worry if you don't know what they do!

Istio consists of a number of components, and you should wait for it to be completely initialized before continuing.
Execute the following commands to wait for the deployment to complete and result `successfully rolled out`:

`oc rollout status deployment/istio-pilot && \
 oc rollout status deployment/istio-mixer && \
 oc rollout status deployment/istio-ca && \
 oc rollout status deployment/istio-ingress && \
 oc rollout status deployment/prometheus && \
 oc rollout status deployment/grafana && \
 oc rollout status deployment/servicegraph && \
 oc rollout status deployment/zipkin`{{execute}}

Once all of the above deployments are complete, we're ready to move on!

