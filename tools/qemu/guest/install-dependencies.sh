#!/bin/bash

# upgrade system
apt-get -qq update
apt-get -qq upgrade

# ensure ssh is running
sudo systemctl enable ssh

# install docker
apt-get -qq install docker.io docker-compose
usermod -aG docker pi
