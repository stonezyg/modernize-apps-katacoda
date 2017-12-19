#!/usr/bin/env bash
#ssh root@host01 "docker pull schtool/foo:latest"
#ssh root@host01 "docker pull schtool/foo2:latest"
ssh root@host01 'for i in {1..200}; do oc policy add-role-to-user system:image-puller system:anonymous && break || sleep 1; done'