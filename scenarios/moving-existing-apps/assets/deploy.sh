#!/usr/bin/env bash

oc login -u developer -p developer
oc new-project rhamt
oc policy add-role-to-user view system:serviceaccount:rhamt:eap-service-account -n rhamt
oc policy add-role-to-user view system:serviceaccount:rhamt:sso-service-account -n rhamt
oc create -n rhamt -f ~/eap-app-secret.json
oc create -n rhamt -f ~/sso-app-secret.json

oc new-app registry.access.redhat.com/rhscl/postgresql-95-rhel7 \
 --name=rhamt-postgresql \
 -e POSTGRESQL_USER=postgresuser \
 -e POSTGRESQL_PASSWORD=postgrespassword \
 -e POSTGRESQL_DATABASE=WindupServicesDS \
 -e POSTGRESQL_MAX_CONNECTIONS=200 \
 -e POSTGRESQL_MAX_PREPARED_TRANSACTIONS=200 \
 -e POSTGRESQL_SHARED_BUFFERS=''


 oc new-app docker.io/schtool/m2m-sso \
   --name="sso" \
            -e DB_SERVICE_PREFIX_MAPPING=rhamt-postgresql=DB     \
            -e DB_JNDI='java:jboss/datasources/KeycloakDS'     \
            -e JAVA_OPTS_APPEND='-Djava.net.preferIPv4Stack=true'     \
            -e DB_USERNAME=postgresuser     \
            -e DB_PASSWORD=postgrespassword     \
            -e DB_DATABASE=WindupServicesDS     \
            -e TX_DATABASE_PREFIX_MAPPING=rhamt-postgresql=DB     \
            -e DB_MIN_POOL_SIZE=''     \
            -e DB_MAX_POOL_SIZE=''     \
            -e DB_TX_ISOLATION=''     \
            -e HTTPS_KEYSTORE_DIR=/etc/eap-secret-volume     \
            -e HTTPS_KEYSTORE=keystore.jks     \
            -e HTTPS_KEYSTORE_TYPE=''     \
            -e HTTPS_NAME=jboss     \
            -e HTTPS_PASSWORD=mykeystorepass     \
            -e JGROUPS_ENCRYPT_SECRET=sso-app-secret     \
            -e JGROUPS_ENCRYPT_KEYSTORE_DIR=/etc/jgroups-encrypt-secret-volume     \
            -e JGROUPS_ENCRYPT_KEYSTORE=jgroups.jceks     \
            -e JGROUPS_ENCRYPT_NAME=''     \
            -e JGROUPS_ENCRYPT_PASSWORD=''     \
            -e JGROUPS_CLUSTER_PASSWORD=0O3nOS0y     \
            -e SSO_ADMIN_USERNAME=admin     \
            -e SSO_ADMIN_PASSWORD=admin     \
            -e SSO_REALM=rhamt     \
            -e SSO_SERVICE_USERNAME=admin     \
            -e SSO_SERVICE_PASSWORD=admin     \
            -e SSO_TRUSTSTORE=''     \
            -e SSO_TRUSTSTORE_DIR=/etc/sso-secret-volume       \
            -e SSO_TRUSTSTORE_PASSWORD=''

oc expose svc/sso

SSO_HOSTNAME="$(oc get route --no-headers -o=custom-columns=HOST:.spec.host sso)"
SSO_URL="http://${SSO_HOSTNAME}/auth"
SSO_PUBLIC_KEY='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhlI4WQ3tbIFE71M0HAO3TfvJFxH0P16wdOSzc/Fr9l8/tOn8cN5sgkGpnyEWcawgv2z4nouUkpV92/vo9fadKr3KVUMVaE3EaR3BmsC0Ct6TY7mYD+sz/yGoSWqwmGYocEJRIXAuMCX3jCu6CKMSV+1qjpcyYqzRaVWTB/EV76Sx+CSh9rEMLl8mE6owxNWQck03KgvWCA70l/LAu1M1bWy1aozoUKiTryX0nTxbHbj4qg3vvHC6igYndJ4zLr30QlCVn1iQ1jXC1MQUJ+Mwc8yZlkhaoAfDS1iM9I8NUcpcQAIn2baD8/aBrS1F9woYYRvo0vFH5N0+Rw4xjgSDlQIDAQAB'

oc new-app docker.io/schtool/m2m-web \
 -e             DB_SERVICE_PREFIX_MAPPING=rhamt-postgresql=DB \
 -e             DB_JNDI='java:jboss/datasources/WindupServicesDS' \
 -e             DB_USERNAME=postgresuser \
 -e             DB_PASSWORD=postgrespassword \
 -e             DB_DATABASE=WindupServicesDS \
 -e             TX_DATABASE_PREFIX_MAPPING=rhamt-postgresql=DB \
 -e             HTTPS_KEYSTORE_DIR=/etc/eap-secret-volume \
 -e             MQ_CLUSTER_PASSWORD=fFYbXNo6 \
 -e             JGROUPS_ENCRYPT_SECRET=eap-app-secret \
 -e             JGROUPS_ENCRYPT_KEYSTORE_DIR=/etc/jgroups-encrypt-secret-volume \
 -e             JGROUPS_ENCRYPT_KEYSTORE=jgroups.jceks \
 -e             JGROUPS_CLUSTER_PASSWORD=JkChTmwL \
 -e             AUTO_DEPLOY_EXPLODED='false' \
 -e             DEFAULT_JOB_REPOSITORY=rhamt-postgresql \
 -e             TIMER_SERVICE_DATA_STORE=rhamt-postgresql \
 -e             SSO_URL=${SSO_URL} \
 -e             SSO_SERVICE_URL='http://sso:8080/auth' \
 -e             SSO_REALM=rhamt \
 -e             SSO_PUBLIC_KEY=${SSO_PUBLIC_KEY} \
 -e             SSO_SAML_KEYSTORE_SECRET=eap7-app-secret \
 -e             SSO_SAML_KEYSTORE=keystore.jks \
 -e             SSO_SAML_KEYSTORE_DIR=/etc/sso-saml-secret-volume \
 -e             SSO_SAML_CERTIFICATE_NAME=jboss \
 -e             SSO_SAML_KEYSTORE_PASSWORD=mykeystorepass \
 -e             SSO_SECRET=mQPrK1Mi \
 -e             SSO_ENABLE_CORS='false' \
 -e             SSO_DISABLE_SSL_CERTIFICATE_VALIDATION='true' \
 -e             SSO_TRUSTSTORE_DIR=/etc/sso-secret-volume

