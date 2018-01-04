So far we haven't started [strangling the monolith](https://www.martinfowler.com/bliki/StranglerApplication.html). To do this we are going to make use of routing capabilities in OpenShift. Each external request coming into OpenShift (unless using a ingress, which we are not) will pass through a route. In our monolith the web page uses client side REST calls to load different parts of pages. 

TODO: Insert image

For the home page the product list is loaded via a REST call to *http://<monolith-hostname>/services/products*. At the moment calls to that URL will still hit product catalog in the monolith. By using a [path based route](https://docs.openshift.com/container-platform/3.7/architecture/networking/routes.html#path-based-routes) in OpenShift we can route these calls to our newly created catalog services instead.

Flow the steps below to create a path based route.

1. Open the openshift console for [Monolith - Applications - Routes](http://[[HOST_SUBDOMAIN]]-8443-[[KATACODA_HOST]].environments.katacoda.com/console/project/coolstore-dev/browse/routes) 
1. Click on create route set **Name** to *catalog-path*, set **Path** to */services/products* and set **Service** to *catalog*
1. Click Save
1. Test the route by running ``curl http://monolith-coolstore-dev.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com/services/products``{{execute}}
1. Now open a web browser against 