In this step, we'll install a sample application into the system. This application
is included in Istio itself for demonstrating various aspects of it, but the application
isn't tied exclusively to Istio - it's an ordinary microservice application that could be
installed to any OpenShift instance with or without Istio.

The sample application is called _Bookinfo_, a simple application that displays information about a book, similar to a single catalog entry of an online book store. Displayed on the page is a description of the book, book details (ISBN, number of pages, and so on), and a few book reviews.

The BookInfo application is broken into four separate microservices:

* **productpage** - The productpage microservice calls the details and reviews microservices to populate the page.
* **details** - The details microservice contains book information.
* **reviews** - The reviews microservice contains book reviews. It also calls the ratings microservice.
* **ratings** - The ratings microservice contains book ranking information that accompanies a book review.

There are 3 versions of the reviews microservice:

* Version v1 doesn’t call the ratings service.
* Version v2 calls the ratings service, and displays each rating as 1 to 5 black stars.
* Version v3 calls the ratings service, and displays each rating as 1 to 5 red stars.

The end-to-end architecture of the application is shown below.

![Bookinfo Architecture](https://blog.openshift.com/wp-content/uploads/istio_bookinfo.png)

## Install Bookinfo

Run the following command:

`sh ~/install-sample-app.sh`{{execute}}

The application consists of the usual objects like Deployments, Services, and Routes.

As part of the installation, we use Istio to "decorate" the application with additional
components (called _Sidecars_)s.

Let's wait for our application to finish deploying.
Execute the following commands to wait for the deployment to complete and result `successfully rolled out`:

`oc rollout status deployment/productpage-v1 && \
 oc rollout status deployment/reviews-v1 && \
 oc rollout status deployment/reviews-v2 && \
 oc rollout status deployment/reviews-v3 && \
 oc rollout status deployment/details-v1 && \
 oc rollout status deployment/ratings-v1`{{execute}}

Once all of the above deployments are complete, we're ready to move on!

