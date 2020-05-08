#!/bin/bash

# upgrade system
apt-get -qq update
apt-get -qq upgrade
apt-get -qq install vim

# ensure ssh is running
systemctl enable ssh

# install docker
#apt-get -qq install docker.io docker-compose
#usermod -aG docker pi
