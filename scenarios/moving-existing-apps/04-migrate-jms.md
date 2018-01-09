In this final step we will again migrate some Weblogic-specific code in the app to use standard Java EE interfaces,
and one JBoss-specific interface.

Our application uses [JMS](https://en.wikipedia.org/wiki/Java_Message_Service) to communicate. Each time an order is placed in the application, a JMS message is sent to
a JMS Topic, which is then consumed by listeners (subscribers) to that topic to process the order using [Message-driven beans](https://docs.oracle.com/javaee/6/tutorial/doc/gipko.html), a form
of Enterprise JavaBeans (EJBs) that allow Java EE applications to process messages asynchronously.

In this case, `InventoryNotificationMDB` is subscribed to and listening for messages from `ShoppingCartService.java`. When
an order comes through the `ShoppingCartService`, a message is placed on the JMS Topic. At that point, the `InventoryNotificationMDB`
receives a message and if the inventory service is below a pre-defined threshold, sends a message to the log indicating that
the supplier of the product needs to be notified.

Unfortunately this MDB was written a while ago and makes use of weblogic-proprietary interfaces to configure and operate the
MDB. RHAMT has flagged this and reported it using a number of issues.

**1. Review the issues**

[Open the report](https://[[HOST_SUBDOMAIN]]-9000-[[KATACODA_HOST]].environments.katacoda.com/) and then
click on the **Issues** tab again:

![Issues](../../assets/moving-existing-apps/project-issues.png)

RHAMT provides helpful links to understand the issue deeper and offer guidance for the migration.

In this case, RHAMT has identified several issues with our use of weblogic MDB interfaces:

* **Call of JNDI lookup** - Our apps use a weblogic-specific [JNDI](https://en.wikipedia.org/wiki/Java_Naming_and_Directory_Interface) lookup scheme.
* **Proprietary InitialContext initialization** - Weblogic has a very different lookup mechanism for InitialContext objects
* **WebLogic InitialContextFactory** - This is related to the above, essentially a Weblogic proprietary mechanism
* **WebLogic T3 JNDI binding** - The way EJBs communicate in Weblogic is over T2, a proprietary implementation of Weblogic.

All of the above interfaces have equivelants in JBoss, however they are greatly simplified and overkill for our application which uses
JBoss EAP's internal message queue implementation provided by [Apache ActiveMQ Artemis](https://activemq.apache.org/artemis/).

Click on each issue to learn more about the problem and possible solutions.

**2. Open the files**

Click here to open the offending files `src/main/java/com/redhat/coolstore/service/InventoryNotificationMDB.java`{{open}} and
``src/main/webapp/WEB-INF/weblogic-ejb-jar.xml``{{open}}.

**3. Understand the changes necessary**

The main logic of this class is in the `onMessage` method. All of the other code in the class is related to the
initialization and management of the MDB itself in the Weblogic environment.

Much of Weblogic's interfaces for EJB components like MDBs reside in Weblogic descriptor XML files. Open
``src/main/webapp/WEB-INF/weblogic-ejb-jar.xml``{{open}} to see one of these descriptors. There are many different configuration
possibilities for EJBs and MDBs in this file, but luckily our application only uses one of them, namely it configures
`<trans-timeout-seconds>` to 30, which means that if a given transaction within an MDB operation takes too
long to complete (over 30 seconds), then the transaction is rolled back and exceptions are thrown. This interface is
Weblogic-specific so we'll need to find an equivalent in JBoss.

Back in `src/main/java/com/redhat/coolstore/service/InventoryNotificationMDB.java`{{open}} you'll also find some
ancillary code in the `init`, `close` and `getInitialContext` methods. These methods were once required of all Weblogic
applications, and while it has been simplified over the years, JBoss provides and even more efficient and declarative way
to configure and manage the lifecycle of MDBs. In this case, we can use annotations to provide the necessary initialization
and configuration logic and settings, obviating the need for any special XML configuration files. We will use the
`@MessageDriven` and `@ActivationConfigProperty` annotations, along with the `MessageListener` interfaces to provide the
same functionality as from Weblogic.

> You should be aware that this type of migration is more involved than the previous migrations, and in real world applications
it will rarely be as simple as changing one line at a time for a migration. Consult the [RHAMT documentation](https://access.redhat.com/documentation/en/red-hat-application-migration-toolkit) for more detail on Red Hat's
Application Migration strategies or contact your local Red Hat representative to learn more about how Red Hat can help you
on your migration path.

**4. Remove the Weblogic EJB Descriptor**

The first step is to remove the unneeded `weblogic-ejb-jar.xml` file. This file is not recognized or processed by JBoss
EAP. Type or click the following command to remove it:

`rm -f src/main/webapp/WEB-INF/weblogic-ejb-jar.xml`{{execute T1}}

While we're at it, let's remove the stub weblogic implementation classes added as part of the scenario.
Run or click on this command to remove them:

`rm -rf src/main/java/weblogic`{{execute T1}}

**5. Remove unneeded class variables and methods**

Open `src/main/java/com/redhat/coolstore/service/InventoryNotificationMDB.java`{{open}}.

JBoss EAP and Java EE define a much richer and more efficient way to configure MDBs through annotations. You can remove
the class variables `JNDI_FACTORY`, `JMS_FACTORY`, `TOPIC`, `tcon`, `tsession` and `tsubscriber` variables from near the
top of the class definition.

Also remove unneeded methods `init()`, `close()`, and `getInitialContext()`. This is handled by JBoss EAP internally.

**5. Add MDB annotations**

To properly initialize and allow JBoss EAP to manage the MDB, add the following annotations to the class definition.
Don't forget the new import statements!

```java
import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;

...

@MessageDriven(name = "InventoryNotificationMDB", activationConfig = {
	@ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "topic/orders"),
	@ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Topic"),
	@ActivationConfigProperty(propertyName = "transactionTimeout", propertyValue = "30"),
	@ActivationConfigProperty(propertyName = "acknowledgeMode", propertyValue = "Auto-acknowledge")})
public class OrderServiceMDB implements MessageListener {

...

```

Remember the `<trans-timeout-seconds>` setting from the `weblogic-ejb-jar.xml` file? This is now set as an
`@ActivationConfigProperty` above. There are pros and cons to using annotations vs. XML descriptors and care should be
taken to consider the needs of the application.

Your MDB should now be properly migrated to JBoss EAP.

The final class code should look like this (click **Copy To Editor** to automatically copy this to the editor and replace the entire code):

<pre class="file" data-filename="./src/main/java/com/redhat/coolstore/service/InventoryNotificationMDB.java" data-target="replace">
package com.redhat.coolstore.service;

import com.redhat.coolstore.model.Order;
import com.redhat.coolstore.utils.Transformers;

import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;
import javax.inject.Inject;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TextMessage;
import java.util.logging.Logger;

@MessageDriven(name = "InventoryNotificationMDB", activationConfig = {
        @ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "topic/orders"),
        @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Topic"),
        @ActivationConfigProperty(propertyName = "transactionTimeout", propertyValue = "30"),
        @ActivationConfigProperty(propertyName = "acknowledgeMode", propertyValue = "Auto-acknowledge")})
public class InventoryNotificationMDB implements MessageListener {

    private static final int LOW_THRESHOLD = 50;

    @Inject
    private CatalogService catalogService;

    @Inject
    private Logger log;

    public void onMessage(Message rcvMessage) {
        TextMessage msg;
        {
            try {
                if (rcvMessage instanceof TextMessage) {
                    msg = (TextMessage) rcvMessage;
                    String orderStr = msg.getBody(String.class);
                    Order order = Transformers.jsonToOrder(orderStr);
                    order.getItemList().forEach(orderItem -> {
                        int old_quantity = catalogService.getCatalogItemById(orderItem.getProductId()).getInventory().getQuantity();
                        int new_quantity = old_quantity - orderItem.getQuantity();
                        if (new_quantity < LOW_THRESHOLD) {
                            log.warning("Inventory for item " + orderItem.getProductId() + " is below threshold (" + LOW_THRESHOLD + "), contact supplier!");
                        }
                    });
                }


            } catch (JMSException jmse) {
                System.err.println("An exception occurred: " + jmse.getMessage());
            }
        }
    }
}
</pre>

When we run our newly-migrated application later you will be able to verify the inventory notification works correctly
by inspecting the log file output.

We'll run the report again to verify our changes in the next step.

## Test the build

Build and package the app using Maven to make sure you code still compiles:

`mvn clean package`{{execute T1}}

If builds successfully (you will see `BUILD SUCCESS`), then let's move on to the next issue! If it does not compile,
verify you made all the changes correctly and try the build again.

Once it builds, let's move on to the next issue!