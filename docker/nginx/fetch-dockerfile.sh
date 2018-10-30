#!/bin/sh -e

curl -O https://raw.githubusercontent.com/nginxinc/docker-nginx/master/mainline/alpine/Dockerfile
patch -p0 < dockerfile-tls13.patch
