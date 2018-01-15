In this step we will re-run the RHAMT report to verify our migration was successfu.

**1. Run the RHAMT CLI against the project**

Click on the below command to clean the old build artifacts and re-execute the RHAMT CLI and analyze the new project:

```
mvn clean && \
~/rhamt-cli-4.0.0.Beta4/bin/rhamt-cli \
  --sourceMode \
  --input ~/projects/monolith \
  --output ~/rhamt-report \
  --overwrite \
  --source weblogic \
  --target eap:7
```{{execute T1}}

**Wait for it to complete before continuing!**. You should see `Report created: /root/rhamt-report/index.html`.

**2. View the results**

The RHAMT CLI generates an updated HTML report.

To view the updated report, first stop the web server:

`clear`{{execute T2 interrupt}}

Then start it again:

`docker run --privileged -v ~/rhamt-report:/usr/share/nginx/html:ro,z -p 9000:80 -it nginx`{{execute T2}}

If this does not work you may need to manually click into the **Terminal 2** and type `CTRL-C` to stop the web server, then restart using
the above command.

Then [reload the report web page](https://[[HOST_SUBDOMAIN]]-9000-[[KATACODA_HOST]].environments.katacoda.com/)

And verify that it now reports 0 Story Points:

You have successfully migrated
this app to JBoss EAP, congratulations!

![Issues](/redhat-middleware-workshops/assets/moving-existing-apps/project-issues-story.png)

> You can ignore the remaining issues, as they are for informational purposes only.

![Issues](/redhat-middleware-workshops/assets/moving-existing-apps/project-issues-gone.png)

## Migration Complete!

Now that we've migrated the app, let's deploy it and test it out and start to explore some of the features that JBoss EAP
plus Red Hat OpenShift bring to the table.

## Before moving on

Stop the report web server by clicking in **Terminal 2** and type CTRL-C to stop the server (or click this command: `clear`{{execute T2 interrupt}})