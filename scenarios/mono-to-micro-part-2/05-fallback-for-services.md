In the previous step we added a client to call the Inventory service. Services calling services is a common practice in Microservices Architecture, but as we add more and more services the likeleyhood of a problem increases dramatically. We should plan for failure to happen and therefor our application logic has to consider that dependent services are not responding.

In the previous step we used the Fegin client from the netflix cloud native libraries to avoid having to write boilerplate code for doing a REST call. However Fegin also have another good property which is that we easily create fallback logic. In this case we will use static inner class since we want the logic for the fallback to be part of the Client and not in a separate class. 

``src/main/java/com/redhat/coolstore/service/CatalogService.java``{{open}}

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/CatalogService.java"
data-target="insert" data-marker="//TODO: Add Callback Factory Component">
    @Component
    static class InventoryClientFallbackFactory implements FallbackFactory<InventoryClient> {
        @Override
        public InventoryClient create(Throwable cause) {
            return new InventoryClient() {
                @Override
                public Inventory getInventoryStatus(@PathVariable("itemId") String itemId) {
                    return new Inventory(itemId,-1);
                }
            };
        }
    }

</pre>

After creating the fallback factory all we have todo is to tell Fegin to use that fallback in case of an issue, by adding the fallbackFactory property to the `@FeginClient` annotation like this:
<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/CatalogService.java"
data-target="insert" data-marker="/* TODO: Set Fallback Factory here*/">
,fallbackFactory = InventoryClient.InventoryClientFallbackFactory.class
</pre>


# Other things to consider
Having fallbacks is good but that also requires that we can correctly detect when a dependent services isn't responding correctly. Besides from not responding a service can also respond slowly causing our services to also respond slow. This can lead to cascading issues that is hard to debug and pinpoint issues with. Other pos