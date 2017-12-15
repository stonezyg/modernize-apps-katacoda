First, execute this working but hacky script to install RHAMT. It will take a few minutes.

``sh ~/deploy.sh``{{execute}}

Run the next command to wait for the deployment to be ready (which should take anywhere from 30 seconds to 2 minutes):

``oc rollout status dc/rhamt-web-console``{{execute}}

Next, click [Red Hat Application Migration Toolkit Web Console](http://rhamt-web-console-rhamt.[[HOST_SUBDOMAIN]]-80-[[KATACODA_HOST]].environments.katacoda.com/rhamt-web/project-list/)
to login to the console with these credentials:

* Username: `rhamt`
* Password: `password`

TBD on the rest, good luck!