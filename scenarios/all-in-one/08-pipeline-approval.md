In previous steps you used an OpenShift Pipeline to automate the process of building and
deploying changes from the dev environment to production.

In this step, we'll add a final checkpoint to the pipeline which will require you as the project
lead to approve the final push to production.

**1. Edit the pipeline**

Ordinarily your pipeline definition would be checked into a source code management system like Git,
and to change the pipeline you'd edit the _Jenkinsfile_ in the source base. For this workshop we'll
just edit it directly to add the necessary changes. You can edit it with the `oc` command but we'll
use the Web Console.

Open the `monolith-pipeline` configuration page in the Web Console (you can navigate to it from
_Builds -> Pipelines_ but here's a quick link):

* [Pipeline Config page](https://[[HOST_SUBDOMAIN]]-8443-[[KATACODA_HOST]].environments.katacoda.com/console/project/coolstore-prod/browse/pipelines/monolith-pipeline?tab=configuration)

On this page you can see the pipeline definition. Click _Actions -> Edit_ to edit the pipeline.

Add a new stage to the pipeline, just before the `Deploy to PROD` step:

```groovy
  stage 'Approve Go Live'
  timeout(time:30, unit:'MINUTES') {
    input message:'Go Live in Production (switch to new version)?'
  }
```

Your final pipeline should look like:

[SCREENSHOT]

Click **Save**.

**2. Make a simple change to the app**

With the approval step in place, let's simulate a new change from a developer who wants to change
the color of the header in the coolstore to green.

First, open `src/main/webapp/app/css/coolstore.css`{{open}}, which contains the CSS stylesheet for the
Coolstore app.

Let's change the background of the header to green. Click **Copy To Editor** to make this change:

<pre class="file" data-filename="src/main/webapp/app/css/coolstore.css" data-target="insert" data-marker="background: blue">
background: green
</pre>

Next, re-build the project in the dev environment:

`mvn clean package -Popenshift`{{execute}}

And re-deploy it to the dev environment:

`oc start-build -n coolstore-dev coolstore --from-file=deployments/ROOT.war`{{execute}}

Now wait for it to complete the deployment:

`oc -n coolstore-dev rollout status dc/coolstore`{{execute}}

And verify that the green header is visible in the dev application:

* [Coolstore - Dev](http://www-coolstore-dev.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com)

[SCREENSHOT]

While the production application is still the original color:

* [Coolstore - Prod](http://www-coolstore-prod.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com)

[SCREENSHOT]

We're happy with this change, so let's promote the new change, using the new approval step!

**3. Run the pipeline again**

Invoke the pipeline once more by clicking **Start Pipeline** on the [Pipeline Config page](https://[[HOST_SUBDOMAIN]]-8443-[[KATACODA_HOST]].environments.katacoda.com/console/project/coolstore-prod/browse/pipelines/monolith-pipeline)

The same pipeline progress will be shown, however before deploying to prod, you will see a prompt:

[SCREENSHOT]

Click on the link for `Input Required`. This will open a new tab and direct you to Jenkins itself, where you can login with
the same credentials as OpenShift:

* Username: `developer`
* Password: `developer`

Accept the permissions, and then you'll find yourself at the approval prompt:

[SCREENSHOT]

**3. Approve the change to go live**

Click **Proceed**, which will approve the change to be pushed to production. You could also have
clicked **Abort** which would stop the pipeline immediately in case the change was unwanted or unapproved.

Once you click **Proceed**, you will see the log file from Jenkins showing the final progress and deployment.

Wait for the production deployment to complete:

`oc rollout -n coolstore-prod status dc/coolstore`{{execute}}

Once it completes, verify that the production application has the new change:

* [Coolstore - Prod](http://www-coolstore-prod.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com)

[SCREENSHOT]

## Congratulations!

You have added a human approval step for all future developer changes.
