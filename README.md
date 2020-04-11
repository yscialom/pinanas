SomeName
======


Description
===========
<name> is a [NAS](https://en.wikipedia.org/wiki/Network-attached_storage "Network-attached storage")
and [media center](https://en.wikipedia.org/wiki/Home_theater_PC)
designed to run on a small computer as a Raspberry PI. Its feature include:

- NAS: share files in your private network
- NAS: host files outside of your private network
- MC: (dis)play photos, music, videos from your NAS on any screen


Hardware
========
TODO


Installation
============
1. Install OpenMediaVault.
2. Execute the following commands:
```bash
apt update && apt upgrade
apt install docker.io docker-compose git net-tools
git clone https://github.com/yscialom/nas.git && cd nas
ifconfig # to get your local IP
./start
```
3. With a web browser, go to `http://<ip>:32400/web`.
