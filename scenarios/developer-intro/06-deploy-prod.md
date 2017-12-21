In the previous scenarios, you deployed the Coolstore monolith using an
OpenShift Template into the `dev-coolstore-monolith` Project. The template
created the necessary objects (BuildConfig, DeploymentConfig, ImageStreams, Services, and Routes)
and gave you as a Developer a "playground" in which to run the app, make
changes and debug.

In this step we are now going to setup a separate production environment and explore some
best practices and techniques for developers and DevOps teams for getting code from
the developer (that's YOU!) to production with less downtime and greater consistency.

## Prod vs. Dev

The existing `dev-coolstore-monolith` build and deployment is used as a developer environment for building new
versions of the app after code changes and deploying them to the development environment.

In a real project on OpenShift, _dev_, _test_ and _production_ environments would typically use different
OpenShift projects and perhaps even different OpenShift clusters.

For simplicity in this scenaro we will only use a _dev_ and _prod_ environment, and no test/QA
environment.


## Create the production environment

We will create and initialize the new production environment using another template
in a separate OpenShift project.

**1. Initialize production project environment**

Execute the following `oc` command to create a new project:

`oc new-project prod-coolstore-monolith --display-name='Coolstore Monolith - Prod'`{{execute}}

This will create a new OpenShift project from which our production application will run.

**2. Add the production elements**

In this case we'll use the production template to create the objects. In previous scenarios you
used the Web Console to create the _dev_ environment using a template. Here we will use the
equivalent process with the `oc` command. Execute:

`oc new-app --template=coolstore-monolith-pipeline-build`{{execute}}

Navigate to the Web Console to see your new app and the components:

[SCREENSHOT]

You can see the production database, and the other elements, but there is no running production
app just yet. The only running app is back in the _dev_ environment, where you used a binary
build to run the app.

In the next step, we'll _promote_ the running app from the _dev_ environment to the _production_
environment. Let's get going!