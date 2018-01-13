#!/usr/bin/env bash
set +x
ssh -T root@host01 <<'EOSSH'
touch ${HOME}/.tqstart
if [ "$(oc whoami)" -eq "system:admin"]; then
  touch ${HOME}/.tqtrue
  MASTER_EXTERNAL_URL=$(oc get route/docker-registry -n default | grep -v NAME | awk '{print $2}' | sed 's/docker\-registry\-default\.//')
  oc adm policy add-role-to-user system:image-puller system:anonymous
  do oc adm policy add-cluster-role-to-user cluster-admin admin
  oc import-image jenkins:v3.7 --from='registry.access.redhat.com/openshift3/jenkins-2-rhel7:v3.7' --confirm -n openshift
  oc export template jenkins-persistent -n openshift -o json | sed 's/jenkins:latest/jenkins:v3.7/g' | oc replace -f - -n openshift
  oc export template jenkins-ephemeral -n openshift -o json | sed 's/jenkins:latest/jenkins:v3.7/g' | oc replace -f - -n openshift

  oc create -n openshift -f https://raw.githubusercontent.com/RedHat-Middleware-Workshops/modernize-apps-labs/master/monolith/src/main/openshift/template-binary.json
  oc create -n openshift -f https://raw.githubusercontent.com/RedHat-Middleware-Workshops/modernize-apps-labs/master/monolith/src/main/openshift/template-prod.json
  touch ${HOME}/.tqtemplate

  yum install tree -y
  oc env dc/router ROUTER_DISABLE_NAMESPACE_OWNERSHIP_CHECK=true -n default

  docker pull registry.access.redhat.com/openshift3/jenkins-2-rhel7:v3.7
  docker pull registry.access.redhat.com/openshift3/jenkins-2-rhel7:latest

  oc login ${MASTER_EXTERNAL_URL} -u developer -p developer --insecure-skip-tls-verify=true
  touch ${HOME}/.tqsuccess

fi

git --git-dir=/root/projects/.git --work-tree=/root/projects pull
EOSSH