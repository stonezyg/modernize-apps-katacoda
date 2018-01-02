#!/usr/bin/env bash
ssh root@host01 "docker pull nginx:latest"
ssh root@host01 "find /root/rhamt-cli-4.0.0.Beta4 -name \*\._\* -print | xargs rm -f"

