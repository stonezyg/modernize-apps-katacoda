This step shows you how Istio-enabled applications can be configured to collect
_trace spans_ using Jaeger. After completing this task, you should
understand all of the assumptions about your application and how to have it
participate in tracing, regardless of what language/framework/platform you
use to build your application.

## Tracing Goals
Developers and engineering organizations are trading in old, monolithic systems
for modern microservice architectures, and they do so for numerous compelling
reasons: system components scale independently, dev teams stay small and agile,
deployments are continuous and decoupled, and so on.

Once a production system contends with real concurrency or splits into many
services, crucial (and formerly easy) tasks become difficult: user-facing
latency optimization, root-cause analysis of backend errors, communication
about distinct pieces of a now-distributed system, etc.

#### What is a trace?
At the highest level, a trace tells the story of a transaction or workflow as
it propagates through a (potentially distributed) system. A trace is a directed
acyclic graph (DAG) of "spans": named, timed operations representing a
contiguous segment of work in that trace.

Each component (microservice) in a distributed trace will contribute its
own span or spans. For example:

![Spans](http://opentracing.io/documentation/images/OTOV_3.png)

This type of visualization adds the context of time, the hierarchy of
the services involved, and the serial or parallel nature of the process/task
execution. This view helps to highlight the system's critical path. By focusing
on the critical path, attention can focus on the area of code where the most
valuable improvements can be made. For example, you might want to trace the
resource allocation spans inside an API request down to the underlying blocking calls.

## Access Jaeger Console
With our application up and our script running to generate loads, visit the Jaeger Console:

* [Jaeger Query Dashboard](http://jaeger-query-istio-system.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com)

[SCREENSHOT]

Select `istio-ingress` from the _Service_ dropdown menu, change the value of **Limit Results** to `200` and click **Find Traces**:

[SCREENSHOT]

In the top right corner, a duration vs. time scatter plot gives a visual representation of the results, showing how and when
each service was accessed, with drill-down capability. The bottom right includes a list of all spans that were traced over the last
hour (limited to 200).

If you click on the top (most recent) trace, you should see the details corresponding
to a recent access to `/productpage`. The page should look something like this:

[SCREENSHOT]

As you can see, the trace is comprised of spans, where each span corresponds to a
BookInfo service invoked during the execution of a `/productpage` request.

The first line represents the external call to the entry point of our application controlled by
 `istio-ingress`. It in thrn calls the `productpage` service. Each line below
represents the internal calls to the other services to construct the result, including the
time it took for each service to respond.

[SCREENSHOT]


To demonstrate the value of tracing, let's inject some faults into our app and discover them via tracing!

## Add some failures

Let's make the ratings service fail 25% of the time. In this case, fail means return an HTTP
503 (Service Unavailable).

```
oc replace -f - <<EOF
apiVersion: config.istio.io/v1alpha2
kind: RouteRule
metadata:
  name: ratings-default
spec:
  destination:
    name: ratings
  precedence: 1
  route:
  - labels:
      version: v1
  httpFault:
    abort:
      percent: 25
      httpStatus: 503
EOF
```{{execute T1}}

This new rule uses the `httpFault` element to fail (HTTP 503) requests going to the `ratings` service 25% of the time.

Now, let's add in an automatic retry (which in the past would have to be implemented by a developer in the application business logic!).
Execute:

```
oc create -f - <<EOF
apiVersion: config.istio.io/v1alpha2
kind: RouteRule
metadata:
  name: retries
spec:
  destination:
    name: ratings
  match:
    source: reviews
  precedence: 1
  httpFault:
    simpleRetry:
      attempts: 5
      perTryTimeout: 2s
EOF
```{{execute T1}}

Now that we have a badly-behaving application, pretend we didn't know what was happening, all we know is that some users are reporting
a slow user experience. Let's take a look at the tracing.

Open the Jaeger console once again:

* [Jaeger Query Dashboard](http://jaeger-query-istio-system.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com)

Select the following:
* Service: `reviews`
* Tags: `error:true` (type it into the field)

[SCREENSHOT]

Then click **Find Traces**:

[SCREENSHOT]

It is these spans that are showing our failures and retry behavior. Click on the first one to expand the trace detail:

[SCREENSHOT]

And then click on the `reviews` service with the `!` symbol:

[SCREENSHOT]

and finally, click on the `+` button next to _Tags_ to show the `503` was indeed received by the `reviews` service:

So now we know which service is causing us problems!

## Before moving on

Let's stop the load generator running against our app. Navigate to **Terminal 2** and type
`CTRL-C` to stop the generator.

## Congratulations!

Distributed tracing speeds up troubleshooting by allowing developers to quickly understand
how different services contribute to the overall end-user perceived latency. In addition,
it can be a valuable tool to diagnosis and troubleshooting in distributed applications.

