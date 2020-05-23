#!/bin/bash

#
## === Actions ===
#

# upgrade system
apt-get -qq update
apt-get -qq upgrade
apt-get -qq install vim docker-compose

# install docker
update-alternatives --set iptables /usr/sbin/iptables-legacy
curl -fsSL https://get.docker.com -o- | sh
usermod -aG docker pi
