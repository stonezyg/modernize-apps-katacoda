One of the properties of container images is that they are immutable. That is, although you can
make changes to the local container filesystem of a running image, the changes are not permanent.
When that container is stopped, any changes are discarded. When a new container is started from
the same container image, it reverts back to what was originally built into the image.

Although any changes to the local container filesystem are discarded when the container is stopped,
it can sometimes be convenient to be able to upload files into a running container. One example of
where this might be done is during development and a dynamic scripting language like javascript or
static content files like html is being used. By being able to modify code in the container, you can modify the application to test
changes before rebuilding the image.

In addition to uploading files into a running container, you might also want to be able to download
files. During development these may be data files or log files created by the application.

In this step you will learn how to transfer files between your local machine and a running
container. You will also learn how you can set up live synchronisation to enable you to make
changes to code on your local machine and have the result immediately used by the application
running in the container without you needing to manually copy them.

As you recall from the last step, we can use `oc rsh` to execute commands inside the running pod.

For our Coolstore Monolith running with JBoss EAP, the application is installed in the `/opt/eap` directory:

`oc rsh dc/coolstore ls -l /opt/eap`{{execute}}

You should see a listing of files in this directory **in the running container**.

**1. Copy files from container**

Let's copy the EAP configuration in use so that we can inspect it. To copy files from a running container
on OpenShift, we'll use the `oc rsync` command. This command expects the name of the pod to copy from,
which can be seen with this command:

`oc get pods --show-all=false`{{execute}}

The output should show you the name of the pod:

```console
NAME                           READY     STATUS    RESTARTS   AGE
coolstore-2-bpkkc              1/1       Running   0          32m
coolstore-postgresql-1-jpcb8   1/1       Running   0          36m
```

The name of my running coolstore monolith pod is `coolstore-2-bpkkc` but yours will be different.

Next, run the `oc rsync` command in your terminal window, substituting the name of *your* pod for `[POD]`:

`oc rsync [POD]:/opt/eap/standalone/configuration/standalone-openshift.xml .`

The output will show that the file was downloaded:

```console
receiving incremental file list
standalone-openshift.xml

sent 30 bytes  received 31,253 bytes  62,566.00 bytes/sec
total size is 31,152  speedup is 1.00
```

Now you can open the file locally using this link: `standalone-openshift.xml`{{open}} and inspect
its contents. This is useful for verifying that the contents of files in your applications are what you expect.

You can also upload files using the same `oc rsync` command but
unlike when copying from the container to the local machine, there is no form for copying a
single file. To copy selected files only, you will need to use the ``--exclude`` and ``--include`` options
to filter what is and isn't copied from a specified directory.

**2. Synchronize project files**

In addition to being able to manually upload or download files when you choose to, the ``oc rsync``
command can also be set up to perform live synchronization of files between your local computer and the container.

That is, the file system of your local computer will be monitored for any changes made to files.
When there is a change to a file, the changed file will be automatically copied up to the container.

This same process can also be run in the opposite direction if required, with changes made in the
container being automatically copied back to your local computer.

An example of where it can be useful to have changes automatically copied from your local computer
into the container is during the development of an application.

For scripted programming languages such as JavaScript, PHP, Python or Ruby, where no separate compilation
phase is required you can perform live code development with your application running inside of OpenShift.

For JBoss EAP applications this requires that the applications be deployed in *exploded* form, meaning that the
files inside the application's WAR file are extracted and exist as individual files on the running EAP instance.

To enable this, we first need to re-deploy our Coolstore monolith as an *exploded* application using the following
command to change the configuration of JBoss EAP to do this automatically:

`oc set env dc/coolstore AUTO_DEPLOY_EXPLODED=true`