
Extending the test

``src/test/java/com/redhat/coolstore/service/CatalogEndpointTest.java``{{open}}

<pre class="file" data-filename="src/test/java/com/redhat/coolstore/service/CatalogEndpointTest.java" data-target="insert" data-marker="//TODO: Add check for Quantity">
.returns(9999,Product::getQuantity)
</pre>

Run the tests

``mvn verify``{{execute interrupt}}

>NOTE: Since we haven't implemented the call to inventory service the test should fail.

Create the Inventory Client

``src/main/java/com/redhat/coolstore/client/InventoryClient.java``{{open}}

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/client/InventoryClient.java" data-target="replace">
package com.redhat.coolstore.client;

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

Add calls to the InventoryClient in the CatalogService

``src/main/java/com/redhat/coolstore/service/CatalogService.java``{{open}}

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

``mvn verify``{{execute}}

Again the test fails because we are trying to call the Inventory service which is not running. We need a away to test this service without having to really on other services. For that we are going to use an API Simulator called [HoverFly](http://hoverfly.io) and particular it's capability to simulate remote APIs. HoverFly is very convinient to use with Unit test and all we have to do is to add a `ClassRule` that will simulate all calls to inventory like this:


``src/test/java/com/redhat/coolstore/service/CatalogEndpointTest.java``{{open}}


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

## Conclusion
TODO