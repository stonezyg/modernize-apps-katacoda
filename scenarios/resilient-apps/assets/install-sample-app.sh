#!/usr/bin/env bash

ISTIO_VERSION=0.3.0
ISTIO_HOME=${HOME}/istio-${ISTIO_VERSION}

cd ${ISTIO_HOME}

oc project istio-system
oc apply -f <(istioctl kube-inject -f samples/bookinfo/kube/bookinfo.yaml)

