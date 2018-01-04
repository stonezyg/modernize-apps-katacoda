#!/usr/bin/env bash
ssh root@host01 'for i in {1..200}; do oc policy add-role-to-user system:image-puller system:anonymous && break || sleep 1; done'
ssh root@host01 'for i in {1..200}; do oc policy add-cluster-role-to-user cluster-admin admin && break || sleep 1; done'

ssh root@host01 "oc import-image jenkins:v3.7 --from='registry.access.redhat.com/openshift3/jenkins-2-rhel7:v3.7' --confirm -n openshift"
ssh root@host01 "oc export template jenkins-persistent -n openshift -o json | sed 's/jenkins:latest/jenkins:v3.7/g' | oc replace -f - -n openshift"
ssh root@host01 "oc export template jenkins-ephemeral -n openshift -o json | sed 's/jenkins:latest/jenkins:v3.7/g' | oc replace -f - -n openshift"

# Install templates
ssh root@host01 "oc create -n openshift -f https://raw.githubusercontent.com/RedHat-Middleware-Workshops/modernize-apps-labs/master/monolith/src/main/openshift/template-binary.json"
ssh root@host01 "oc create -n openshift -f https://raw.githubusercontent.com/RedHat-Middleware-Workshops/modernize-apps-labs/master/monolith/src/main/openshift/template-prod.json"

ssh root@host01 "docker pull registry.access.redhat.com/openshift3/jenkins-2-rhel7:v3.7"
ssh root@host01 "docker pull registry.access.redhat.com/openshift3/jenkins-2-rhel7:latest"

ssh root@host01 "git --git-dir=/root/projects --work-tree=/root/projects pull"
