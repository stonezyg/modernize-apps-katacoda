In this step we will implement POST operation for adding a product. The UI in Coolstore Monolith uses a POST operation when a user click `Add to Cart`. 

![Add To Cart](../../assets/reactive-microservices/add-product.png)

The UI will then issue a POST request to `/services/cart/<cartId>/<prodId>/<quantity>`. However when adding a product to the ShoppingCartItem we need an actual `Product` object.

![Add To Cart](../../assets/reactive-microservices/cart-model.png)

So our implementation of this service needs to retrieve a Product object from the `CatalogService`. Let's get started with this implementation.

**1. Add route**

Let's start by adding a router, by adding the following where at the `//TODO: Create add router` marker in class `CartServiceVerticle` 

<pre class="file" data-filename="./src/main/java/com/redhat/coolstore/CartServiceVerticle.java" data-target="insert" data-marker="//TODO: Create add router">
router.post("/services/cart/:cartId/:itemId/:quantity").handler(this::addToCart);
</pre>

**2. Create handler for our route**

Our newly create route needs a handler. This method should look like this `void addCart(RoutingContext rc)`. The handler should add a product to the shopping cart, but it also have to consider that there might already be product with the same id in the shopping cart already.

Adding the following at the `//TODO: Add handler for adding a Item to the cart` marker in class `CartServiceVerticle`

<pre class="file" data-filename="./src/main/java/com/redhat/coolstore/CartServiceVerticle.java" data-target="insert" data-marker="//TODO: Add handler for adding a Item to the cart">
    private void addToCart(RoutingContext rc) {
        logger.info("Retrieved " + rc.request().method().name() + " request to " + rc.request().absoluteURI());

        String cartId = rc.pathParam("cartId");
        String itemId = rc.pathParam("itemId");
        int quantity = Integer.parseInt(rc.pathParam("quantity"));

        ShoppingCart cart = getCart(cartId);

        boolean productAlreadyInCart = cart.getShoppingCartItemList().stream()
            .anyMatch(i -> i.getProduct().getItemId().equals(itemId));

        if(productAlreadyInCart) {
            cart.getShoppingCartItemList().forEach(item -&gt; {
                if (item.getProduct().getItemId().equals(itemId)) {
                    item.setQuantity(item.getQuantity() + quantity);
                    sendCart(cart,rc);
                }
            });
        } else {
            ShoppingCartItem newItem = new ShoppingCartItemImpl();
            newItem.setQuantity(quantity);
//TODO: Get product from Catalog service and add it to the ShoppingCartItem
        }
    }
</pre>

We are not completely done with the addToCart method yet. We have a TODO for Getting a product from the `CatalogService`. Since we do not want to block the thread while waiting for the `CatalogService` to respond this should be a async operation. 

**3. Create a Async method for retrieving a Product**

Normally in Java you would probably implement this method as `Product getProduct(String prodId)`. However we need this operation to be Async. One way to do this is pass a `Handler<AsyncResult<T>>` as an argument. `T` would be replaced with return type we want, which in our case is `Product`.

For making calls to external HTTP services Vert.x supplies a WebClient. The `WebClient` methods like `get()`, `post()` etc and is very easy to use. In our case we are going to use get and pass in port, hostname and uri. We are also going to set a timeout for the operation. So let's first add those to our configuration. 

Copy this into the configuration file (or click the button):

<pre class="file" data-filename="./src/main/resources/config-default.json" data-target="replace">
{
    "http.port" : 8082,
    "catalog.service.port" : 8081,
    "catalog.service.hostname" : "localhost",
    "catalog.service.timeout" : 3000

}
</pre>

We are now ready to create our `getProduct` method

Adding the following at the `//TODO: Add method for getting products` marker in class `CartServiceVerticle`

<pre class="file" data-filename="./src/main/java/com/redhat/coolstore/CartServiceVerticle.java" data-target="insert" data-marker="//TODO: Add method for getting products">
    private void getProduct(String itemId, Handler<AsyncResult<Product>> resultHandler) {
        WebClient client = WebClient.create(vertx);
        Integer port = config().getInteger("catalog.service.port", 8080);
        String hostname = config().getString("catalog.service.hostname", "localhost");
        Integer timeout = config().getInteger("catalog.service.timeout", 0);
        client.get(port, hostname,"/services/product/"+itemId)
            .timeout(timeout)
            .send(handler -&gt; {
                if(handler.succeeded()) {
                    Product product = Transformers.jsonToProduct(handler.result().body().toJsonObject());
                    resultHandler.handle(Future.succeededFuture(product));
                } else {
                    resultHandler.handle(Future.failedFuture(handler.cause()));
                }


            });
    }
</pre>

Now we can call this method from the `addToCart` method and pass a Lambda call back. 

Adding the following at the `//TODO: Get product from Catalog service and add it to the ShoppingCartItem`

<pre class="file" data-filename="./src/main/java/com/redhat/coolstore/CartServiceVerticle.java" data-target="insert" data-marker="//TODO: Get product from Catalog service and add it to the ShoppingCartItem">
                this.getProduct(itemId, reply -> {
                    if (reply.succeeded()) {
                        newItem.setProduct(reply.result());
                        cart.addShoppingCartItem(newItem);
                        send(cart,rc);
                    } else {
                        sendError(rc);
                    }
                });
</pre>

To summarize our `addToCart` handler will now first check if the product already exists in the shopping cart. If it does exist we update the quantity and then send the response. If it doesn't exist we call the catalog service to retrieve the data about the product, create a new ShoppingCartItem, set the quantity, add the retrieved product, add it the `ShoppingCartItem`, add the item to the shopping cart and then finally send the response to the client. 

Phu! That wasn't easy... However, in real life thing are never as easy as they sometimes seem to appear. Rather than present you with a set of Hello World demos we believe that it's much more educational to use a more realistic example. 


**4. Test our changes**

Let's first test to update the quantity for a product that is already in the shopping cart

Start the cart service
``mvn compile vertx:run``{{execute T1 interrupt}}

```curl -s http://localhost:8082/services/cart/99999 | grep -A7  "\"itemId\" : \"329299\"" | grep quantity```{{execute T2}}

This will return the quantity like below, but the actual number may be different.

`"quantity" : 3`

Now let's call our addToCart method.

```curl -s -X POST http://localhost:8082/services/cart/99999/329299/1 | grep -A7  "\"itemId\" : \"329299\"" | grep quantity```{{execute T2}}

This should now return a shopping cart where one more instance of the product is added, because of our grep commands you would see something like this:

`"quantity" : 4`

Now let's try adding a new product.

The CartService depends on the CatalogService and just like in the Spring Boot example we could have created mocks for calling the Catalog Service, however since our example is already complex, we will simply test it with the CatalogService running. 

>**NOTE:** The CatalogService in it's turn depends on the InventoryService to retrieve the quantity in stock, however since we don't really care about that in the Shopping Cart we will just rely on the Fallback method of CatalogService when testing. 

First lets check if the catalog service is still running locally.

```jps -l | grep com.redhat.coolstore.RestApplication```{{execute T1 interrupt}}

If this command doesn't return anything we need to start the Catalog application in a separate terminal like this:

```cd ~/projects/catalog; mvn clean spring-boot:run```{{execute T2}}

To test to add a product we are going to use a new shopping cart id like this.

```curl -s -X POST http://localhost:8082/services/cart/88888/329299/1```{{execute T3}}

This should print the follow:

```
{
  "cartId" : "88888",
  "orderValue" : 34.99,
  "retailPrice" : 34.99,
  "discount" : 0.0,
  "shippingFee" : 0.0,
  "shippingDiscount" : 0.0,
  "items" : [ {
    "product" : {
      "itemId" : "329299",
      "price" : 34.99,
      "name" : "Red Fedora",
      "desc" : "Official Red Hat Fedora",
      "location" : null,
      "link" : null
    },
    "quantity" : 1
  } ]
}%   
```


## Congratulations

Wow! You have now successfully created a Reactive microservices that are calling another REST service asynchronously. 

However, looking at the output you can see that the discount and shippingFee is 0.0, which also means that the orderValue (price after shipping and discount) and retailPrice (sum of all products prices) are equal. That is because we haven't implemented the Shipping and Promotional Services yet. That's what we are going to do in the next scenario.








