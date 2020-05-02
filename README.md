SomeName
======


Description
===========
SomeName is a [NAS](https://en.wikipedia.org/wiki/Network-attached_storage "Network-attached storage")
and [media center](https://en.wikipedia.org/wiki/Home_theater_PC)
designed to run on a small computer as a Raspberry PI. Its feature include:

- NAS: share files in your private network
- NAS: host files outside of your private network
- MC: (dis)play photos, music, videos from your NAS on any screen


Hardware
========

Emulation
---------

It is possible to emulate the hardware of a Raspberry Pi with Qemu. Scripts in
[tools/qemu](/tools/qemu) automate the installation and start of an emulated
board with an OS.

### Linux

In a build directory,

```bash
make -f /path/to/tools/qemu/Makefile
./start
```

This downloads (and install) qemu, rasbian and all needed files. Once done,
`make -f /path/to/tools/qemu/Makefile clean` removes temporary files and
`make -f /path/to/tools/qemu/Makefile distclean` deletes all files.

### Windows

TODO


Installation
============
1. Install OpenMediaVault.
2. Execute the following commands:
```bash
apt install docker.io docker-compose git net-tools
git clone https://github.com/yscialom/nas.git
cd nas
./start
```
3. With a web browser, go to `http://<ip>:32400/web`.
