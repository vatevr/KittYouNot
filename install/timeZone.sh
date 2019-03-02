#!/bin/sh

TIME_ZONE=${1}

apt-get install -y tzdata && \
   ln -sf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && \
   dpkg-reconfigure -f noninteractive tzdata