#!/usr/bin/env bash
ssh root@host01 "cd /root/projects && git clone https://github.com/RedHat-Middleware-Workshops/modernize-apps-labs"
ssh root@host01 "docker pull nginx:latest"
