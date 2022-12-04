PiNanas Installation procedure
=============================

Requirements
------------

### Hardware

PiNanas will need a linux-based host, with:
- 10GB free disk space
- 4GB RAM, 8GB suggested
- An access to Internet
- Optionnally: a GPU suited to your needs (video transcoding & playing)

### Software

During installation or operation, PiNanas requires:
- GNU utils
- python3 and pip
- docker and docker-compose
- a wildcard (sub)domain name (e.g. `*.home.example.com`); read
[How to get a domain name?](get-a-domain-name.md "docs/get-a-domain-name.md") for more information.

### Operating Systems

Have been tested: Debian, Ubuntu, Raspbian. PiNanas is expected to be compatible with a wide range of
linux-based OS. Please do try new ones and [report](https://github.com/yscialom/pinanas/issues) your findings.

### Architectures

Both amd64 and arm are supported. Please [report](https://github.com/yscialom/pinanas/issues) any findings regarding a
specific version of amd64 or arm.


Download
--------

### Download

#### Direct download
Go and download our [latest release](https://github.com/yscialom/pinanas/releases) Source code.
Unzip the content of `pinanas-$version/` anywhere on your PiNanas host. The following will assume you unzipped it in
`/path/to/pinanas`.

#### Via git
From your PiNanas host, anywhere:
```bash
git clone --depth 1 --branch master https://github.com/yscialom/pinanas.git
```
The following will assume you clonned it in `/path/to/pinanas`.


User
----

You are free to run PiNanas with any user with:
- rights on the docker daemon, and
- read rights on the `/path/to/pinanas` directory.
`root` is a possibility, although nor recommended.

For instance, create a `pinanas` user:
```bash
sudo useradd --groups docker --system pinanas
```


PiNanas installation directory
------------------------------

Create the installation directory for PiNanas. The following will assume it is `/opt/pinanas`.
```bash
sudo mkdir -p /opt/pinanas
sudo chown pinanas:pinanas /opt/pinanas
```


Settings
--------

### Define your settings
In the instalation directory, create a file `settings.yml` from [`src/settings.yml.sample`](/src/settings.yml.sample)
and fill in all mandatory values:
```bash
cd /opt/pinanas
cp /path/to/pinanas/src/settings.yml.sample settings.yml
chmod 600 settings.yml # contains passwords
nano settings.yml
```

Save and exit.

### DNS Provider
PiNanas needs delegation on your domain name. To this end, you must create and fill in the appropriate variables to
PiNanas. Read [DNS Provider Variables](dns-provider-variables.md "docs/dns-provider-variables.md") for a complete
guide.

### Special care needed on `settings.yml`
This file is both _secret_ and _precious_. It contains passwords to both PiNanas administration and to
external services. As such, it must be kept private, only readable to user having administration rights on the PiNanas
host, and the `pinanas` user itself. If you run PiNanas on a disposable virtual machine, make a copy of `settings.yml`
and store it properly on a second device.

Ideally, `settings.yml` is built upon deployment and secrets are kept by a dedicated tool.


Install
-------

From your installation directory, run `src/configure.sh`:
```bash
cd /opt/pinanas
/path/to/pinanas/src/configure.sh
```
If you made important changes to `settings.yml` and want to regenerate PiNanas, run with `--force`:
```bash
cd /opt/pinanas
/path/to/pinanas/src/configure.sh --force
```

Your installation is now complete.


Start
-----

From your installation directory, run `docker-compose up -d`:
```bash
cd /opt/pinanas
docker-compose up -d
```

### First Start

The first start of PiNanas can be slow, especially on low-end hardware. To better monitor it, you have:
- `/path/to/pinanas/test/wait-for-containers.sh`: this script gives you information on containers, their status and
  health.
- Traefik dashboard: go to `https://traefik-dashboard.home.example.com` (replace `home.example.com` with your actual
domain). This dashboard will help you troubleshoot missing services, routers, ...
- Netdata: go to `https://resources.home.example.com` (replace `home.example.com` with your actual domain). This
monitoring tool will help you follow hardware and software resources consumption on your PiNanas host.

### Setting up your personnal dashboard

Heimdall has been selected as PiNanas dashboard. It is a simple and great page to access and quicky check the status
of all of PiNanas services. Go to `https://apps.home.example.com` (replace `home.example.com` with your actual domain)
and click the ![Haimdall Application List button](res/heimdall-application-list.png) button and add your applications. You can find their urls on Traefik dashboard (`https://traefik-dashboard.home.example.com`).

### Sign in with Authelia

When possible, we have set services to use Authelia as its authentification manager. Some tools, like Nextcloud or
Jellyfin, allow authentification by Authelia or internally. If possible, always use Authelia for a fully secured and
centralized authentification system.

Some services require a two-factor authentification
([2FA](https://en.wikipedia.org/wiki/Multi-factor_authentication "Wikipedia — Multi-factor authentication")). To
access to those tool, set up Authelia 2FA. Read
[Authelia — One Time Password](https://www.authelia.com/overview/authentication/one-time-password/) for a complete
guide on how to setup your second-factor authentification.
