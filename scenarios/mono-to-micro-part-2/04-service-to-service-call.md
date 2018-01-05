## Extending the test

In the [Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development) style, let's first extend our test to test the Inventory functionality (which doesn't exist):

Click on ``src/test/java/com/redhat/coolstore/service/CatalogEndpointTest.java``{{open}}

Then again click **Copy to Editor** to paste the code into the existing test:

<pre class="file" data-filename="src/test/java/com/redhat/coolstore/service/CatalogEndpointTest.java" data-target="insert" data-marker="//TODO: Add check for Quantity">
.returns(9999,Product::getQuantity)
</pre>

Run the tests:

``mvn verify``{{execute interrupt}}

Since we haven't implemented the call to inventory service the test should fail. You should get **BUILD FAILURE** and if you scroll
up a bit you'll see the test failed:

```console
Results :

Failed tests:
  CatalogEndpointTest.check_that_endpoint_returns_a_correct_list:69 expected:<[9999]> but was:<[0]>

Tests run: 4, Failures: 1, Errors: 0, Skipped: 0
```

## Create the Inventory Client

To talk to the existing inventory service (written with WildFly Swarm in the last scenario), we'll need to call it through
HTTP REST. Constructing the call, providing the right arguments, and dealing with failures are challenging and boring to do every
time, so we'll use Netflix Feign to wrap our HTTP calls with a tyle-safe, Java-friendly API:

Click to open: ``src/main/java/com/redhat/coolstore/client/InventoryClient.java``{{open}}

And paste in the code as before:

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/client/InventoryClient.java" data-target="replace">
package com.redhat.coolstore.client;

//TODO: add import for InventoryClient
import com.redhat.coolstore.model.Inventory;
import feign.hystrix.FallbackFactory;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.cloud.netflix.feign.FeignClient;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@FeignClient(name="inventory" /* TODO: Set Fallback Factory here*/)
public interface InventoryClient {

    @RequestMapping(method = RequestMethod.GET, value = "/services/inventory/{itemId}", consumes = {MediaType.APPLICATION_JSON_VALUE})
    Inventory getInventoryStatus(@PathVariable("itemId") String itemId);

    //TODO: Add Fallback factory here 
}
</pre>

##Add calls to the InventoryClient in the CatalogService.

Open: ``src/main/java/com/redhat/coolstore/service/CatalogService.java``{{open}}

And paste:

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/CatalogService.java" data-target="insert" data-marker="//TODO: Autowire Inventory Client">
    @Autowired
    InventoryClient inventoryClient;
</pre>

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/CatalogService.java" data-target="insert" data-marker="//TODO: Update the quantity for the product by calling the Inventory service">
    product.setQuantity(inventoryClient.getInventoryStatus(product.getItemId()).getQuantity());
</pre>

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/CatalogService.java" data-target="insert" data-marker="//TODO: Update the quantity for the products by calling the Inventory service">
    productList.parallelStream()
                .forEach(p -> {
                    p.setQuantity(inventoryClient.getInventoryStatus(p.getItemId()).getQuantity());
                });
</pre>

Don't forget the import!

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/CatalogService.java" data-target="insert" data-marker="//TODO: add import for InventoryClient">
import com.redhat.coolstore.client.InventoryClient;
</pre>

Finally, add the necessary configuration to the `application-default.properties` file:

<pre class="file" data-filename="src/main/resources/application-default.properties" data-target="insert" data-marker="#TODO Configure netflix libraries">
eureka.client.enabled=false
ribbon.eureka.enable=false
ribbon.listOfServers=inventory:8080
feign.hystrix.enabled=true
</pre>

Now, re-run the tests:

``mvn verify``{{execute}}

Again the test fails because we are trying to call the Inventory service which is not running. We need a way to test this service without having to rely on other services.
For that we are going to use an API Simulator called [HoverFly](http://hoverfly.io) and in particular its capability to simulate
remote APIs. HoverFly is very convenient to use with Unit tests and all we have to do is to add a `ClassRule` that will simulate
all calls to inventory like this:

Open the file: ``src/test/java/com/redhat/coolstore/service/CatalogEndpointTest.java``{{open}}

And paste:

<pre class="file" data-filename="src/test/java/com/redhat/coolstore/service/CatalogEndpointTest.java"
data-target="insert" data-marker="//TODO: Add ClassRule for HoverFly Inventory simulation">
    @ClassRule
    public static HoverflyRule hoverflyRule = HoverflyRule.inSimulationMode(dsl(
            service("inventory:8080")
                    //TODO: Add  timeout to test fallback
                    .get(startsWith("/services/inventory"))
                    .willReturn(success(json(new Inventory("9999",9999))))

    )); 
</pre>

Now run the tests again.

``mvn verify``{{execute}}

It worked! The HoverFly mock endpoint supplied the needed data.

## Congratulations!

You now have the framework for retrieving products from the product catalog and enriching the data with inventory data from
an external service. But what if that external inventory service does not respond? That's the topic for the next step.
