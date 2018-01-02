#!/usr/bin/env bash
ssh root@host01 "yum install tree -y"
ssh root@host01 "oc env dc/router ROUTER_DISABLE_NAMESPACE_OWNERSHIP_CHECK=true -n default"
