Now that we migrated the application you are probably eager to test it. To test it we locally we first need to install JBoss EAP.



**1. Add a OpenShift profile**



At the `<!-- TODO: Add OpenShift profile here -->` we are going to add a the following configuration to the pom.xml

<pre class="file" data-filename="pom.xml" data-target="insert" data-marker="<!-- TODO: Add OpenShift profile here -->">
          &lt;profile&gt;
              &lt;id&gt;openshift&lt;/id&gt;
              &lt;build&gt;
                  &lt;plugins&gt;
                      &lt;plugin&gt;
                          &lt;artifactId&gt;maven-war-plugin&lt;/artifactId&gt;
                          &lt;version&gt;2.6&lt;/version&gt;
                          &lt;configuration&gt;
                              &lt;webResources&gt;
                                  &lt;resource&gt;
                                      &lt;directory&gt;${basedir}/src/main/webapp/WEB-INF&lt;/directory&gt;
                                      &lt;filtering&gt;true&lt;/filtering&gt;		
                                      &lt;targetPath&gt;WEB-INF&lt;/targetPath&gt;
                                  &lt;/resource&gt;
                              &lt;/webResources&gt;
                              &lt;outputDirectory&gt;deployments&lt;/outputDirectory&gt;
                              &lt;warName&gt;ROOT&lt;/warName&gt;		
                          &lt;/configuration&gt;
                      &lt;/plugin&gt;
                  &lt;/plugins&gt;
              &lt;/build&gt;
          &lt;/profile&gt;
</pre>



1. Click on the openshift tab next to terminal tab
![OpenShift Console](../../assets/default-picture.jpg)
1. This will open a new browser with the openshift console
![OpenShift Console](../../assets/default-picture.jpg)
1. Login using username *developer* and password *developer*
![OpenShift Console](../../assets/default-picture.jpg)
1. Click create new project
![OpenShift Console](../../assets/default-picture.jpg)
1. Give the project the **Name:** `coolstore-dev` and **Display Name:**`Coolstore Monolith - Dev`, leave the **Description** empty.
![OpenShift Console](../../assets/default-picture.jpg)
1. Click the **Add to project** button
![OpenShift Console](../../assets/default-picture.jpg)
1. Search for `Coolstore Monolith using binary build` template.
![OpenShift Console](../../assets/default-picture.jpg)
1. Click Next.

This will deploy a development project for us that consists of a PostgreSQL database and JBoss EAP. But it will not start a build for our application.

In this development project we have selected to use a process called binary builds, which means that instead of pointing to a public Git Repository and have the S2I build process download, build, and then create a container image for us we are going to build locally and just upload the artifact (e.g. .war file). The binary deployment will speed up the build process significantly. 

Login from the command line:


``mvn clean package -Popenshift``{{execute}}

``oc login [[HOST_SUBDOMAIN]]-8443-[[KATACODA_HOST]].environments.katacoda.com -u developer -p developer``{{execute}}

``oc project coolstore-dev``{{execute}}

``oc start-build coolstore --from-file=deployments/ROOT.war``{{execute}}

``oc rollout status dc/coolstore``{{execute}}

Check the OpenShift console
![OpenShift Console](../../assets/default-picture.jpg)

Test the application by clicking on the route
![OpenShift Console](../../assets/default-picture.jpg)

Now you are using the same application that we built locally on OpenShift. That wasn't to hard










