From the OpenShift Web Console overview page, click on the route link to open the sample application UI:

![Route Link](../../assets/mono-to-micro-part-1/routelink.png)

This will open up the sample application UI in a new browser tab:

![App UI](../../assets/mono-to-micro-part-1/app.png)

The app will begin polling the inventory as before and report success:

![Greeting](../../assets/mono-to-micro-part-1/inventory.png)

Now you will corrupt the service and cause its health check to start failing.
To simulate the app hanging, let's pause the underlying service so it stops responding. Execute:

`oc rsh dc/inventory pkill -STOP java`{{execute T1}}

This will execute the Linux `pkill` command and send the STOP signal to the running Java process in the container.

Check out the application sample UI page and notice it is now failing to access the inventory data, and the
`Last Successful Fetch` counter starts increasing, indicating that the UI cannot access inventory. This could have
been caused by an overloaded server, a bug in the code, or any other reason that could make the application
unhealthy.

![Greeting](../../assets/mono-to-micro-part-1/inventory-fail.png)

At this point, return to the OpenShift web console and click on the _Overview_ tab for the project. Notice that the
dark blue circle has now gone light blue, indicating the application is failing its _liveness probe_:

![Not Ready](../../assets/mono-to-micro-part-1/notready.png)

After too many failures, OpenShift will forcibly kill the pod and container running the service, and spin up a new one to take
its place. Once this occurs, the light blue circle should return to dark blue. This should take about 20 seconds.

Return to the same sample app UI (without reloading the page) and notice that the UI has automatically
re-connected to the new service and successfully accessed the inventory once again:

![Greeting](../../assets/mono-to-micro-part-1/inventory.png)
