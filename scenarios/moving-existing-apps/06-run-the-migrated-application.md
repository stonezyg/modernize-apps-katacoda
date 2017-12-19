Now that we migrated the application you are probably eager to test it. To test it we locally we first need to install JBoss EAP.

Run the following command in the terminal window.

``unzip $HOME/Downloads/jboss-eap-7.1.zip -d $HOME``{{execute}}

We should also set the `JBOSS_HOME` environment variable like this:

``export JBOSS_HOME=$HOME/jboss-eap-7.1``{{execute}}

Done! That is how easy it is to install JBoss EAP. 



Open the `pom.xml` file.
``pom.xml``{{open}}

## Adding JBoss EAP dependencies
After migrating the code we are now using much more standard Java EE components, but it's still a good idea to make sure that we build the project using JBoss EAP artifacts. This is done, by adding a dependency management section.

At the comment `<!-- TODO: Add dependency management here -->` insert the following XML.
<pre class="file" data-filename="pom.xml" data-target="insert" data-marker="<!-- TODO: Add dependency management here -->">
    &lt;dependencyManagement&gt;
        &lt;dependencies&gt;
            &lt;dependency&gt;
                &lt;groupId&gt;org.jboss.bom&lt;/groupId&gt;
                &lt;artifactId&gt;jboss-eap-javaee7&lt;/artifactId&gt;
                &lt;version&gt;7.1.0.GA&lt;/version&gt;
                &lt;type&gt;pom&lt;/type&gt;
                &lt;scope&gt;import&lt;/scope&gt;
            &lt;/dependency&gt;
        &lt;/dependencies&gt;
    &lt;/dependencyManagement&gt;
</pre>

## The maven-wildfly-plugin
JBoss EAP comes with a nice maven-plugin tool that can stop, start, deploy, and configure JBoss EAP directly from Apache Maven. Let's add that the pom.xml file.

At the `TODO: Add wildfly plugin here` we are going to add a the following configuration

<pre class="file" data-filename="pom.xml" data-target="insert" data-marker="            <!-- TODO: Add wildfly plugin here -->">
            &lt;plugin&gt;
                &lt;groupId&gt;org.wildfly.plugins&lt;/groupId&gt;
                &lt;artifactId&gt;wildfly-maven-plugin&lt;/artifactId&gt;
                &lt;version&gt;1.2.1.Final&lt;/version&gt;
                &lt;!-- TODO: Add configuration here --&gt;
            &lt;/plugin&gt;
</pre>

Next we are going to add some configuration. First we need to point to our JBoss EAP installation using the `jboss-home` configuration. After that we will also have to tell JBoss EAP to use the profile configured for full Java EE, since it defaults to use the Java EE Web Profile. This is done by adding a `server-config` and set it to value `standalone-full.xml`

<pre class="file" data-filename="pom.xml" data-target="insert" data-marker="                <!-- TODO: Add configuration here -->">
                &lt;configuration&gt;
                    &lt;jboss-home&gt;${env.JBOSS_HOME}&lt;/jboss-home&gt;
                    &lt;server-config&gt;standalone-full.xml&lt;/server-config&gt;
                    &lt;!-- TODO: Add JMS Topic here --&gt;
                &lt;/configuration&gt;
</pre>

Since our application is using a JMS Topic we are also need to add the configuration for that by adding the following at the ```<-- TODO: Add JMS Topic here -->``` comment

<pre class="file" data-filename="pom.xml" data-target="insert" data-marker="                    <!-- TODO: Add JMS Topic here -->">
                    &lt;resources&gt;
                        &lt;resource&gt;
                            &lt;address&gt;subsystem=messaging-activemq,server=default,jms-topic=orders&lt;/address&gt;
                            &lt;properties&gt;
                                &lt;entries&gt;!!["topic/orders"]&lt;/entries&gt;
                            &lt;/properties&gt;
                        &lt;/resource&gt;
                    &lt;/resources&gt;
</pre>

We are now ready to build and test the project

## Building and testing

After the changes that we have done we are now ready to test that our migrated project builds and runs. Because of the `maven-wildfly-plugin` this can now be done with a single command.

``mvn clean package wildfly:start wildfly:add-resource wildfly:deploy``{{execute}}






