## What is a Fraction?

WildFly Swarm is defined by an unbounded set of capabilities. Each piece of functionality is called a fraction.
Some fractions provide only access to APIs, such as JAX-RS or CDI; other fractions provide higher-level capabilities,
such as integration with RHSSO (Keycloak).

The typical method for consuming WildFly Swarm fractions is through Maven coordinates, which you add to the pom.xml
file in your application. The functionality the fraction provides is then packaged with your application into an
_Uberjar_.  An uberjar is a single Java .jar file that includes everything you need to execute your application.
This includes both the runtime components you have selected, along with the application logic.

** 1. Examine the uberjar**

You can see the uberjar (in the `target/` directory) that you built in previous steps:

```ls -l target/*.jar```{{execute}}

You should see the uberjar named `inventory-1.0.0-SNAPSHOT-swarm.jar` in the listing. This jar file is executed
using `java -jar` when using `mvn wildfly-swarm:run` or when the application is deployed to OpenShift.

An uberjar is useful for many continuous integration and continuous deployment (CI/CD) pipeline styles,
in which a single executable binary artifact is produced and moved through the testing, validation, and
production environments in your organization.


## What is a Health Check?

A key requirement in any managed application container environment is the ability to determine when the application is in a ready state. Only when an
application has reported as ready can the manager (in this case OpenShift) act on the next step of the deployment process. OpenShift
makes use of various _probes_ to determine the health of an application during its lifespan. A _readiness_
probe is one of these mechanisms for validating application health and determines when an
application has reached a point where it can begin to accept incoming traffic. At that point, the IP
address for the pod is added to the list of endpoints backing the service and it can begin to receive
requests. Otherwise traffic destined for the application could reach the application before it was fully
operational resulting in error from the client perspective.

Once an application is running, there are no guarantees that it will continue to operate with full
functionality. Numerous factors including out of memory errors or a hanging process can cause the
application to enter an invalid state. While a _readiness_ probe is only responsible for determining
whether an application is in a state where it should begin to receive incoming traffic, a _liveness_ probe
is used to determine whether an application is still in an acceptable state. If the liveness probe fails, the
kubelet will destroy the pod.

More in depth validation can be created to not only confirm the application can be accessed, but also
validate dependencies, such as databases or caches, are available. In our case, the inventory service
uses an external database, and is one of the dependencies that should be accessible prior to an
application being made available for end users. Otherwise, users would receive errors when
performing the most common functions of the application, such as adding and removing items from
their grocery list since the backend persistence store is unavailable.

Alternate methods can also be
implemented to manage application availability and usability when the database is not available.
Extended validation of the application and its dependencies can be implemented using several
different strategies. First, is to expose health checking logic within the application, such as on an HTTP
endpoint on the /health context which is common feature found in a number of web frameworks including
WildFly Swarm.

Alternatively, the logic for determining application health can be delivered as a script and executed as
a command against the container (See the listing below). A non zero exit code from the command
indicates the application is no longer healthy.

In our case we will implement the health check logic in a REST endpoint and let WildFly Swarm publish
that logic on the `/health` endpoint for use with OpenShift.

** 2. Add `monitor` fraction**

WildFly Swarm includes the `monitor` fraction which automatically adds health check infrastructure to your
application when it is included as a fraction in the project. Click **Copy To Editor** to insert the new dependencies
into the `pom.xml` file:

<pre class="file" data-filename="pom.xml" data-target="insert" data-marker="<!-- Add monitor fraction -->">
        &lt;!-- Add monitor fraction --&gt;
        &lt;dependency&gt;
            &lt;groupId&gt;org.wildfly.swarm&lt;/groupId&gt;
            &lt;artifactId&gt;monitor&lt;/artifactId&gt;
        &lt;/dependency&gt;
</pre>


By adding the `monitor` fraction, Fabric8 will automatically add a _readinessProbe_ and _livenessProbe_ to the OpenShift
_DeploymentConfig_, published at `/health`, once deployed to OpenShift. But you still need to implement the logic behind
the health check, which you'll do next.

