Installation
============

Settings
--------

### Define settings
Create a file `settings.yml` from `settings.yml.sample` and fill in all values. See "Get your DNS API keys" below for how to set `PINANAS_DNS_PROVIDER_VARS`.

### Get your DNS API keys

#### OVH

Go to [OVH's API Key creation page](https://eu.api.ovh.com/createToken/) and fill in:
- "Account ID or email address": your OVH account name
- "Password": your OVH account password
- "Script Name": a title for your usage, e.g. "pinanas"
- "Script Description": a description for your usage, e.g. "Handle dns challenge for wildcard certificate issue for **.domainname"
- "Validity": "Unlimited"
- "Rights":
-- "GET /domain/zone/*"
-- "PUT /domain/zone/*"
-- "POST /domain/zone/*"
-- "DELETE /domain/zone/*"
And click "Create keys".

You will be given an Application Key, an Application Secret and a Consumer Key. Keep those secret and safe as you cannot retrieve them.

Update `settings.yml` and add the following values:
```yaml
PINANAS_DNS_PROVIDER_VARS:
  - { name: OVH_APPLICATION_KEY, value: <Your Application Key> }
  - { name: OVH_APPLICATION_SECRET, value: <Your Application Secret> }
  - { name: OVH_CONSUMER_KEY, value: <Your Consumer Key> }
```

Prepare
-------

Run `prepare.sh`. If you made important changes and want to regenerate pinanas, run with `--force`.

Start
-----

Run `docker-compose up -d`.
