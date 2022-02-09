PiNanas
========

Description
===========
PiNanas is a [NAS](https://en.wikipedia.org/wiki/Network-attached_storage "Network-attached storage"),
[media center](https://en.wikipedia.org/wiki/Home_theater_PC) and home-hosted set of services
designed to run on a small computer like a Raspberry PI. Its features include:

- Share files in your private network
- Host files outside of your private network
- (Dis)play photos, music, videos from your NAS on any screen
- Scan, search & manage scans
- Protect home network of ads and malwares
- ...


Installation
============

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
- a wildcard (sub)domain name (e.g. `*.home.example.com`)


Download
--------

### Via git
From your PiNanas host, anywhere:
```bash
git clone --depth 1 --branch develop https://github.com/yscialom/pinanas.git
```

### Direct download
Go and donwload our [latest release](https://github.com/yscialom/pinanas/releases) Source code.
Unzip it anywhere.


Settings
--------

Create the installation directory for PiNanas, e.g. in `/opt/pinanas` and go there:
```bash
sudo mkdir -p /opt/pinanas
cd /opt/pinanas
```

### Define your settings
Create a file `settings.yml` from [`src/settings.yml.sample`](src/settings.yml.sample) and fill in all values:
```bash
cp /path/to/pinanas/src/settings.yml.sample settings.yml
chmod 600 settings.yml # contains passwords
nano settings.yml
```
See [Get your DNS API keys](#get-your-dns-api-keys) below for how to set `PINANAS_DNS_PROVIDER_VARS`.

### Get your DNS API keys

#### OVH

Go to [OVH's API Key creation page](https://eu.api.ovh.com/createToken/) and fill in:
- `Account ID or email address`: your OVH account name
- `Password`: your OVH account password
- `Script Name`: a title for your usage, e.g. "PiNanas"
- `Script Description`: a description for your usage, e.g. "Handle dns challenge for wildcard certificate issue for **.domainname"
- `Validity`: "Unlimited"
- `Rights`:
  - "GET /domain/zone/*"
  - "PUT /domain/zone/*"
  - "POST /domain/zone/*"
  - "DELETE /domain/zone/*"

And click `Create keys`.

You will be given an Application Key, an Application Secret and a Consumer Key. Keep those secret and safe as you cannot retrieve them.

Update `settings.yml` and add the following values:
```yaml
PINANAS_DNS_PROVIDER_VARS:
  - { name: OVH_APPLICATION_KEY, value: <Your Application Key> }
  - { name: OVH_APPLICATION_SECRET, value: <Your Application Secret> }
  - { name: OVH_CONSUMER_KEY, value: <Your Consumer Key> }
  - { name: OVH_ENDPOINT, value: <Your OVH zone, e.g. ovh-eu> }
```

Install
-------

From your installation directory, run:
```bash
/path/to/pinanas/src/configure.sh
```
If you made important changes and want to regenerate PiNanas, run with `--force`.

Your installation is now complete.

Start
=====

From your installation directory, run `docker-compose up -d`.
