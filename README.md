PiNanas
========


Description
===========
PiNanas is a [NAS](https://en.wikipedia.org/wiki/Network-attached_storage "Network-attached storage")
and [media center](https://en.wikipedia.org/wiki/Home_theater_PC)
designed to run on a small computer like a Raspberry PI. Its feature include:

- NAS: share files in your private network
- NAS: host files outside of your private network
- MC: (dis)play photos, music, videos from your NAS on any screen


Installation
============

PiNanas can be installed in two flavors:
- PiNanas OS: as an operating system working out-of-the-box;
- PiNanas App: as a docker-compose based software suite.

PiNanas OS
-----------

### Hardware

Get your hands on a Raspberry Pi 4, a good 32GB microSD card, an USB
external hard drive and you're good to go!


### Software

PiNanas OS is delivered as a compressed raw image. To install it on your NAS device,
simply byte-copy this image to your device primary disk, e.g. the microSD card of a
Raspberry Pi.

#### Instruction on Linux
1. Insert the device primary disk on your linux machine.
2. Check the device of the device primary disk, for instance by running `dmesg|tail` just after having inserted it.
3. Download the lastest release of PiNanas OS.
4. Uncompress it running `tar -xaf pinanas-os-*.gz`
5. Byte-copy the extracted image with `sudo dd if=pinanas-os-*.img of=/dev/your_device_from_step_2 bs=512k`
6. Insert the device primary disk back to your NAS device and boot it.

#### Instruction on Windows
TODO

PiNanas App
------------

On a linux host with docker and docker-compose installed, copy the [app](/app)
directory somewhere and run `app/start`.


Usage
=====

Once your NAS device is running PiNanas OS, the following services are provided:

- Plex
- Nextcloud
- SteamLink

Plex
----
Plex is a client-server media system for your movies, TV shows, music, pictures, and internet-based content. It uses a Server to house your media library and player Apps to playback the media.
The server can acquire content from files, iTunes, iPhoto, Aperture, or the Internet and the music library is automatically organized by ID3 or M4A tags, such as title, artist, album, genre, year, and popularity.
The basic Plex player app runs on multitudes of platforms and devices: Amazon Fire TV, Android TV, Apple TV, Chromecast, iOS, smart TVs and Blu-ray devices, webOS, Opera TV, PlayStation 3, PlayStation 4, Roku, Sonos, TiVO, Windows Phone, Xbox 360, and Xbox One.

See more informations on https://support.plex.tv/articles/


NextCloud
---------
Nextcloud is an open-source client-server software suite for creating and using file hosting service like Dropbox, OneDrive or Google Drive.
Nextcloud files are stored in conventional directory structures, accessible via WebDAV if necessary. User files are encrypted during transit and optionally at rest. Nextcloud can synchronise with local clients running Windows (Windows XP, Vista, 7, 8, and 10), macOS (10.6 or later), or various Linux distributions. It permits user and group administration (via OpenID or LDAP). Content can be shared by defining granular read/write permissions between users and groups.

Nextcloud is modular, it can be extended with plugins to implement extra functionality including:
-    calendars (CalDAV)
-    contacts (CardDAV)
-    streaming media (Ampache)
-    gallery
-    document viewer tools from within Nextcloud
-    connection to Dropbox, Google Drive and Amazon S3

SteamLink
---------
SteamLink is a software applications that enable streaming of Steam content from a personal computer or a Steam Machine wirelessly to a mobile device or other monitor. The device acting as the Steam Link enables a game controller connected to it to be used to control the game over the connection to the home computer.


Emulation (experimental, see issues)
====================================

It is possible to emulate the hardware of a Raspberry Pi with Qemu. Scripts in
[os](/os/linux-host) automate the installation and start of an emulated
board with an OS. This is also how is built the PiNanas OS image.


Build
=====
The PiNanas OS image is built automatically under QEMU simulating a Raspberry Pi 4.
You'll need a linux machine (x86 or amd64) with root permissions, qemu-img and
qemu-system-arm installed.

1. Create a build directory and go into it `cd $(mktemp -d)`.
2. Prepare an alias to call make: `alias make='make -f /path/to/PiNanas/os/linux-host/Makefile'`
3. Build the following targets:
```bash
make build       # builds pinanas-os-$version.img
make qemulaion   # prepare everything to emulate the OS
./start          # emulate the OS fir its first start; this can take dozen minutes to hours
make release     # package pinanas-os-$version.gz
```
