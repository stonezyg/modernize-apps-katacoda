In the previous scenario you learned how to take an existing application to the cloud with JBoss EAP and OpenShift,
and you got a glimpse into the power of OpenShift for existing applications.

In this scenario you will go deeper into how to use the OpenShift Container Platform as a developer to build,
deploy, and debug applications. We'll focus on the core features of OpenShift as it relates to developers, and
you'll learn typical workflows for a developer (develop, build, test, deploy, debug, and repeat).

## Let's get started

If you are not familiar with the OpenShift Container Platform, it's worth taking a few minutes to understand
the basics of the platform as well as the environment that you will be using for this workshop.

The goal of OpenShift is to provide a great experience for both Developers and System Administrators to
develop, deploy, and run containerized applications.  Developers should love using OpenShift because it
enables them to take advantage of both containerized applications and orchestration without having the
know the details.  Developers are free to focus on their code instead of spending time writing Dockerfiles
and running docker builds.

OpenShift is a full platform that incorporates several upstream projects while also providing additional
features and functionality to make those upstream projects easier to consume.  The core of the platform is
containers and orchestration.  For the container side of the house, the platform uses images based upon
the docker image format.  For the orchestration side, we have a put a lot of work into the upstream
Kubernetes project.  Beyond these two upstream projects, we have created a set of additional Kubernetes
objects such as routes and deployment configs that we will learn how to use during this course.

Both Developers and Operators communicate with the OpenShift Platform via one of the following methods:

### Command Line Interface

The command line tool that we will be using as part of this training is called the *oc* tool. You used this briefly
in the last scenario.

This tool is written in the Go programming language and is a single executable that is provided for
Windows, OS X, and the Linux Operating Systems.

### Web Console

OpenShift also provides a feature rich Web Console that provides a friendly graphical interface for
interacting with the platform. You can always access the Web Console using the link provided just above
the Terminal window on the right:

![OpenShift Console Tab](../../assets/developer-intro/openshift-console-tab.png)

### REST API

Both the command line tool and the web console actually communicate to OpenShift via the same method,
the REST API.  Having a robust API allows users to create their own scripts and automation depending on
their specific requirements.  For detailed information about the REST API, check out the [official documentation](https://docs.openshift.org/latest/rest_api/index.html)

During this workshop, you will be using both the command line tool and the web console.  However, it
should be noted that there are plugins for several integrated development environments as well.
For example, to use OpenShift from the Eclipse IDE, you would want to use the official [JBoss Tools](https://tools.jboss.org/features/openshift.html) plugin.

### The Environment

During this training course you will be using a hosted OpenShift environment that is created just for you.
This environment is not shared with other users of the system.  Because each user taking this training has
their own environment, we had to make some concessions to ensure the overall platform is stable and used
only for this training.  For that reason, your environment will only be active for today. As you progress
through the scenarios, your environment will remain the same, as long as you use the same browser
session (don't worry if your browser crashes, the persistence is cookie-based and should survive).

The OpenShift environment that has been created for you is running the latest version of our open source
project called OpenShift Origin.  This deployment is a self contained environment that provides everything
you need to be successful in learning the platform.  This includes such things as the command line, web
console, and public URLs.

Now that you know how to interact with OpenShift, let's focus on some core concepts that you as a developer
will need to understand as you are building your applications!