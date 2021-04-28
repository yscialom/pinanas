PiNanas
========


Description
===========
PiNanas is a [NAS](https://en.wikipedia.org/wiki/Network-attached_storage "Network-attached storage"),
[media center](https://en.wikipedia.org/wiki/Home_theater_PC) and game console
designed to run on a small computer like a Raspberry PI. Its feature include:

- NAS: share files in your private network
- NAS: host files outside of your private network
- ~~MC: (dis)play photos, music, videos from your NAS on any screen~~
- GC: stream Steam games from a running PC


Installation
============

PiNanas can be installed in three flavors:
- PiNanas Galaxy: as an ansible playbook;
- ~~PiNanas OS: as an operating system working out-of-the-box;~~
- ~~PiNanas App: as a docker-compose based software suite.~~

PiNanas Galaxy
------------

### Pi preparation

1. On a Raspberry Pi, install the latest Raspberry Pi OS. See official documentation
[Installing operating system images](https://www.raspberrypi.org/documentation/installation/installing-images/).
2. Boot your Raspbeey Pi with a screen, keyboard and mouse; follow the installation wizard.
3. Reboot.

### Play book

On a linux host with ansible installed and an [ssh key](https://www.ssh.com/academy/ssh/keygen "ssh-keygen documentation"),
run [`ansible/install.sh`](ansible/install.sh).


Usage
=====

SteamLink
---------
SteamLink is a software applications that enable streaming of Steam content from a
personal computer or a Steam Machine wirelessly to a mobile device or other monitor.
The device acting as the Steam Link enables a game controller connected to it to be
used to control the game over the connection to the home computer.

