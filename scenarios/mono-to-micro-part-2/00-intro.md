In the previous scenarios, you learned how to take an existing monolithic and break one out a single service using WildFly Swarm. Since WildFly Swarm is using Java EE much of the technologies from the monolith could be reused straight up, like JPA and JAX-RS. The previous scenario resulted in you creating an inventory service, but so far we haven't started the strangeling the monolith. That is because the inventory service is never called directly by the UI. It's a backend service that is only used by the Catalog Service. In this scenario, you will create the catalog service and the catalog service will call the inventory services. When you are ready, you will change the route so that the UI calls our new service.  

To implement this, we are going to use Spring Framework. The reason for using Spring for this service is to introduce you to Spring Development, and how [Red Hat OpenShift Application Runtimes](https://developers.redhat.com/products/rhoar) helps to make Spring development on Kuberenetes easy. In real life, the reason for choosing Spring vs. WF Swarm mostly depends on personal preferences, like existing knowledge, etc. At the core Spring and Java EE are very similar. 


TODO: Add picture showing how catalog and inventory interact.

## What is Spring Framework? 

Spring is one of the most popular Java Frameworks and offers an alternative to the Java EE programming model. Spring is also very popular for build application based on Microservices Architecture. Spring Boot is a popular tool in the Spring eco system that helps with organizing/using 3rd party libraries together with Spring and also provides a mechanism for boot strapping embeddable runtimes, like Apache Tomcat. Bootable applications (sometimes also called fat jars) fits the container model very well since in a container platform like OpenShift responsibilities like starting, stopping and monitoring applications are then handled by the container platform instead of an Application Server.

## Aggregate microservices calls
Another thing you will learn in this scenario is one of the techniques to aggregate services using service-to-service calls. Other possible solutions would be to use a microservices gateway or combine services using client-side logic. 