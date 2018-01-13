This workshop is split into several _scenarios_, each of which focuses on a specific
area related to Application Modernization and Transformation with Red Hat technologies.

Each scenario in turn has a number of steps that you follow to complete the scenario in the
order shown on the front page.

![Landing Page](/redhat-middleware-workshops/assets/getting-started/home.png)

If you get stuck, you can always freely move between the steps with the left and right
arrows at the top of the instructions in case you missed a step, or start the entire scenario
from the beginning by simply reloading your browser's page.

As you complete each step within a scenario, click the **Continue** button to move on to the next
step.

## OpenShift

Your environment also has a complete instance of OpenShift Container Platform running for your use, which you
will learn much more about later on. For now, make sure you can login to OpenShift using this command (click
on it!):

`oc login [[HOST_SUBDOMAIN]]-8443-[[KATACODA_HOST]].environments.katacoda.com -u developer -p developer --insecure-skip-tls-verify=true`{{execute T1}}
