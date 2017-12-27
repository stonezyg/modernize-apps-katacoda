In this step you will debug the coolstore application using Java remote debugging and
look into line-by-line code execution as the code runs inside a container on OpenShift.

## Witness the bug

The  CoolStore applications seem to have a bug that causes the inventory status for one of the
products to be not shown at all:

![Inventory Status Bug](https://katacoda.com/openshift-roadshow/assets/debug-coolstore-bug.png)

Since the product list is provided by the monolith, take a look into the logs to see if there are any warnings:

`oc logs dc/coolstore | grep -i warning`{{execute}}

Oh! Something seems to be wrong with the inventory for the product id **444437**

```console
...
WARNING [com.redhat.coolstore.utils.Transformers] (default task-83) Inventory for Atari 2600 Joystick[444437] unknown and missing
...
```

## Check the REST API Response

Invoke the Product Catalog API using `curl` for the suspect product id to see what actually
happens when the UI tries to get the catalog:

`curl -v http://www-coolstore-dev.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com/services/products/444437`{{execute}}

The response clearly shows that the inventory values for `location` and `link` and `quantity` are not being returned properly (they should not be `null`):

```json
{"itemId":"444437","name":"Atari 2600 Joystick","desc":"Based on the original design of the joystick controller for the famed Atari 2600 console, the Joystick from Retro-Bit features a similar stick and single-button layout. ","price":240.0,"location":null,"quantity":0,"link":null}
```

Let's debug the app to get to the bottom of this!

## Enable remote debugging

Remote debugging is a useful debugging technique for application development which allows
looking into the code that is being executed somewhere else on a different machine and
execute the code line-by-line to help investigate bugs and issues. Remote debugging is
part of  Java SE standard debugging architecture which you can learn more about it in [Java SE docs](https://docs.oracle.com/javase/8/docs/technotes/guides/jpda/architecture.html).

The EAP image on OpenShift has built-in support for remote debugging and it can be enabled
by setting the `JAVA_OPTS_APPEND` environment variables on the deployment config for the pod
that you want to remotely debug. This will pass additional variables to the JVM when it starts up.

`oc set env dc/coolstore JAVA_OPTS_APPEND="-Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=n"`{{execute}}

This will cause a re-deployment of the app to enable the remote debugging agent on TCP port 8787.

Wait for the re-deployment to complete before continuing by executing:

`oc rollout status dc/coolstore`{{execute}}

The re-deployment also invoked a new pod, so let's update our environment variable again:

`export COOLSTORE_DEV_POD_NAME=$(oc get pods --selector deploymentconfig=coolstore -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}')`{{execute}}

Verify the variable holds the name of your new pod with:

`echo $COOLSTORE_DEV_POD_NAME`{{execute}}

## Expose debug port locally

Next, let's use `oc port-forward` to enable us to connect to `localhost:8787` to debug. Without this,
we would have to expose the running app to everyone outside the OpenShift cluster, so instead we
will just open it for ourselves with `oc port-forward`.

Execute:

`oc port-forward $COOLSTORE_DEV_POD_NAME 8787 &`{{execute}}

This will forward traffic to/from the container's port 8787 to your `localhost` port 8787.

You are all set now to start debugging using the tools of you choice.

Remote debugging can be done using the widely available
Java Debugger (`jdb`) command line or any modern IDE like **JBoss
Developer Studio (Eclipse)** and **IntelliJ IDEA**.

## Use `jdb` to debug

The [Java Debugger (JDB)](http://docs.oracle.com/javase/8/docs/technotes/tools/windows/jdb.html)
is a simple command-line debugger for Java. The `jdb` command is included by default in
Java SE and provides inspection and debugging of a local or remote JVM. Although JDB is not
the most convenient way to debug Java code, it's a handy tool since it can be run on any environment
that Java SE is available.

The instructions in this section focuses on using JDB however if you are familiar with JBoss Developer
Studio, Eclipse or IntelliJ you can use them for remote debugging.

Start JDB by pointing at the folder containing the Java source code for the application under debug:

`jdb -attach localhost:8787 -sourcepath :src/main/java/`{{execute}}

## Add a breakpoint

Now that you are connected to the JVM running inside the Coolstore pod on OpenShift, add
a breakpoint to pause the code execution when it reaches the Java method handling the
REST API `/services/products` Review the `src/main/java/com/redhat/coolstore/service/ProductService.java`{{open}} class and note that the
`getProductByItemId()` is the method where you should add the breakpoint.

Add a breakpoint by executing:

`stop in com.redhat.coolstore.service.ProductService.getProductByItemId`{{execute}}

## Trigger the bug again

In order to pause code execution at the breakpoint, you have to invoke the REST API once more.

Click this link to invoke the REST API from your browser:

* [Coolstore REST API](http://www-coolstore-dev.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com/services/products/444437)

The code execution pauses at the `getProductByItemId()` method. You can verify it
using the `list`{{execute}} command to see the source code in the terminal window where
you started JDB. The arrow shows which line is to execute next:

`list`{{execute}}

You'll see an output similar to this.

```
default task-3[1] list
24            return cm.getCatalogItems().stream().map(entity -> toProduct(entity)).collect(Collectors.toList());
25        }
26
27        public Product getProductByItemId(String itemId) {
28 =>         CatalogItemEntity entity = cm.getCatalogItemById(itemId);
29            if (entity == null)
30                return null;
31            return Transformers.toProduct(entity);
32        }
33
```

Execute one line of code using `next` command so the the CatalogItemEntity object is
retrieved from the database.

`next`{{execute}}

Use `locals` command to see the local variables and verify the retrieved
object from the database.

`locals`{{execute}}

You'll see an output similar to this.

```
default task-2[1] locals
Method arguments:
itemId = "444437"
Local variables:
entity = instance of com.redhat.coolstore.model.CatalogItemEntity(id=20281)
```

Look at the value of the `entity` variable using the `print` command:

`print entity`{{execute}}

```
 entity = "ProductImpl [itemId=444437, name=Atari 2600 Joystick, desc=Based on the original design of the joystick controller for the famed Atari 2600 console, the Joystick from Retro-Bit features a similar stick and single-button layout. , price=240.0]"
```

Looks good so far. What about the `inventory` object that's part of this object? Execute:

`print entity.getInventory()`{{execute}}

```
 entity.getInventory() = null
```

Oh! Did you notice the problem?

The `inventory` object which is the object retrieved from the database
for the provided product id is `null` and is returned as the REST response! The non-existing
product id is not a problem on its own because it simply could mean this product is discontinued
and removed from the Inventory database but it's not removed from the product catalog database
yet. The bug is however caused because the code returns this `null` value instead of a sensible
REST response. If the product id does not exist, a proper JSON response stating a zero inventory
should be returned instead of `null`

Exit the debugger using the `quit` command:

`quit`{{execute}}

## Fix the code

Open `src/main/java/com/redhat/coolstore/service/ProductService.java`{{open}}. We'll add some code to add in
a sensible value for an Inventory in case it is not there. To make this change, add in this code to the end
of the `getProductByItemId` method (or simply click **Copy to Editor** to do it for you):


<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/ProductService.java" data-target="insert" data-marker="// Return the entity">
        // Add inventory if needed and return entity
        if (entity.getInventory() == null) {
            InventoryEntity i = new InventoryEntity();
            i.setItemId(itemId);
            i.setLink("http://redhat.com");
            i.setLocation("Unavailable");
            i.setQuantity(0);
            entity.setInventory(i);
        }
</pre>

## Re-build and redeploy the application

With our code fix in place, let's re-build the application to test it out. To rebuild, execute:

`mvn package -Popenshift`{{execute}}

Let's use our new `oc rsync` skills to re-deploy the app to the running container. Execute:

`oc rsync deployments/ $COOLSTORE_DEV_POD_NAME:/deployments --no-perms`{{execute}}

After a few seconds, reload the [Coolstore Application](http://www-coolstore-dev.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com) in your browser
and notice now the application behaves properly and displays `Inventory Unavailable` whereas before it was totally and confusingly blank.

Well done and congratulations for completing this scenario!

## Before continuing

Let's kill the `oc port-forward` processes we started earlier in the background. Execute:

`kill %1`{{execute}}

On to the next challenge!