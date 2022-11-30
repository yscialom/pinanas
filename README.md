PiNanas
========

**Cloud services, safely hosted at home.**

![Heimdall application dashboard: PiNanas homepage](docs/res/pinanas-apps.png)


Description
-----------
PiNanas is a private cloud platform with a wild range of services included. It can be safely hosted at home or on any
privately-managed infrastructure. It is modular, flexible and open to extensions. Built with security and ease of use
in mind, PiNanas will empower you to transform any hardware (old computer, Raspberry Pi, ...) into a homelab and
private cloud.

Access your files from anywhere around the world. Never lose a photo anymore. Wonder no more how to play videos on
your TV.

### What can I do with PiNanas?

PiNanas includes:
- A private cloud platform:
  - [Nextcloud](https://nextcloud.com "Nextcloud homepage"):
    store, access and share your files, and more...
  - [Jellyfin](https://jellyfin.org  "Jellyfin homepage"):
    manage and stream your films and tv shows.
- Network management:
  - [AdGuard Home](https://adguard.com/en/adguard-home/overview.html "AdGuard Home homepage"):
    protect your privacy and filter out advertising on all devices.
- Security and monitoring tools:
  - [Traefik](https://traefik.io/traefik "Traefik homepage"):
    simplify networking complexity while designing, deploying, and operating applications.
  - [Authelia](https://www.authelia.com "Authelia homepage"):
    rely on the Single Sign-On Multi-Factor portal for all PiNanas apps.
  - [Netdata](https://www.netdata.cloud "Netdata homepage"):
    monitor your infrastructure resources.

[![Continuous Integration](https://github.com/yscialom/pinanas/actions/workflows/continuous-integration.yml/badge.svg?branch=develop)](https://github.com/yscialom/pinanas/actions/workflows/continuous-integration.yml)
[![Continuous Deplyment](https://github.com/yscialom/pinanas/actions/workflows/continuous-deployment.yml/badge.svg?branch=develop)](https://github.com/yscialom/pinanas/actions/workflows/continuous-deployment.yml)


Installation
------------

### Requirements

#### Hardware

PiNanas will need a linux-based host, with:
- 10GB free disk space
- 4GB RAM, 8GB suggested
- An access to Internet
- Optionnally: a GPU suited to your needs (video transcoding & playing)

#### Software

During installation or operation, PiNanas requires:
- GNU utils
- python3 and pip
- docker and docker-compose
- a wildcard (sub)domain name (e.g. `*.home.example.com`); read
[How to get a domain name?](docs/get-a-domain-name.md "docs/get-a-domain-name.md") for more information.

Read [INSTALL](docs/INSTALL.md "docs/INSTALL.md") for a step-by-step guide on how to install PiNanas at home.


Contributing
------------

PiNanas is highly modular and can be extended. You can:
- [Link an external service to PiNanas](docs/external-services.md "docs/external-services.md") into its perimeter,
  enhancing interoperability, security and visibility of applications.
- [Contribute](docs/CONTRIBUTING.md "docs/CONTRIBUTING.md") to this repository: feature request, bug
  report, pull request...


Who are we?
-----------

PiNanas was born in 2020 during the Covid Pandemic when two friends discussed their frustrations around attempts to
setup Plex in a controlled environment, on low-cost hardware (Raspberry Pi 3).

It was around this time that [Techno Tim](https://www.technotim.live "Techno Tim homepage") published [a video on
Youtube](https://youtu.be/liV3c9m_OX8 "Put Wildcard Certificates and SSL on EVERYTHING - Traefik Tutorial") on how to
setup Traefik on a homelab, the first of a series on homelab services. These videos have been a continuous source of
inspiration for us. What we tinkered with became its own thing, and The Wife named it PiNanas: a
[NAS](https://en.wikipedia.org/wiki/Network-attached_storage "Network-attached storage") on a
[Pi](https://www.raspberrypi.org/ "Raspberry Pi")!

We'd be sincerly pleased to see you finding interest in our toy project.

— [Yankel Scialom](https://github.com/yscialom "YSC on Github") and
[glevil](https://github.com/glevil "glevil on Github").
