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
- Owncloud (TODO)
- SteamLink (TODO)

Plex
----
TODO

NextCloud
---------
TODO

SteamLink
---------
TODO


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
