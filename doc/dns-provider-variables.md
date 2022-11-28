DNS Provider Variables
=====================

Context
-------

PiNanas is hosted on a domain name through HTTPS. The S in HTTPS stands for _Secure_, feature made possible by
[Transport Layer Security](https://en.wikipedia.org/wiki/Transport_Layer_Security "Wikipedia — Transport Layer
Security") (TLS) or, formerly, Secure Sockets Layer (SSL). TLS and TLS certificates are what ensure the client is
connected to the right server, and that communication is encrypted both ways.

In order for PiNanas to be recognized by network tools such that mainstream web browser, it must obtain and expose a
valid TLS certificate for its domain. Such certificates can be obtained for free by organisations like
[Let's Encrypt](https://letsencrypt.org/ "Let's Encrypt homepage"). Let's Encrypt only requires one thing in return:
for PiNanas to _proove_ it _owns_ the domain a certificate is requested for.

Proof of ownership can be provided
[by many means](https://doc.traefik.io/traefik/https/acme/#the-different-acme-challenges "Traefik Proxy documentation
— Let's Encrypt"); PiNanas is configured to take the DNS Challenge, as it is the only one not requiring PiNanas to be
available from the Internet.

Answering the DNS Challenge is all automated, but requires PiNanas to be allowed to alter your DNS entry at your
registrar. This is securely done through API Keys that limit in scope and in time what PiNanas can do on your domain
registration.


What DNS Provider are supported?
-------------------------------

A list of
[supported DNS Providers](https://doc.traefik.io/traefik/https/acme/#providers "Traefik Proxy documentation — Let's
Encrypt") can be found on Traefik documentation website. Make sure your provider is listed.


How to provide API Keys to PiNanas?
----------------------------------

In your `settings.yml` file (see [INSTALL](INSTALL.md#settings "doc/INSTALL.md") for more information), you will find
the variable `provider`. You need to fill in the details for your provider. It is composed of three fields:
- The `name` (or code) of your provider as defined by
  [ACME](https://en.wikipedia.org/wiki/Automatic_Certificate_Management_Environment "Wikipedia —
  Automatic Certificate Management Environment").
- The `email` (or identifier) your provider identifies you to.
- The `api` list of variables as defined by ACME.
```yaml
pinanas:
  network:
    dns:
      provider:
        name: "provider_code"
        email: "your@email"
        api:
          - name: "VARIABLE_1"
            value: "VALUE_1"
          - name: "VARIABLE_2"
            value: "VALUE_2"
          - ...
```

In order to identify the right information for your provider, head on to Traefik list of
[supported DNS Providers](https://doc.traefik.io/traefik/https/acme/#providers "Traefik Proxy documentation — Let's
Encrypt") and find yours. Click the left-most link "Ad conf" to access this provider's documentation page on
[Lego](https://go-acme.github.io/lego/ "Let's Encrypt client and ACME library written in Go.").

Next step is to create your API Keys and provide them into your `settings.yml`. You will find guidance on the creation
of API keys on the Lego's documentation page for your provider.


Examples
--------

### OVH

See [OVH documentaiton page on Lego](https://go-acme.github.io/lego/dns/ovh/ "Lego — OVH").

Go to [OVH's API Key creation page](https://eu.api.ovh.com/createToken/) and fill in:
- `Account ID or email address`: your OVH account name
- `Password`: your OVH account password
- `Script Name`: a title for your usage, e.g. "PiNanas"
- `Script Description`: a description for your usage, e.g. "Handle dns challenge for wildcard certificate issue for
**.example.com"
- `Validity`: "Unlimited"
- `Rights`:
  - "GET /domain/zone/*"
  - "PUT /domain/zone/*"
  - "POST /domain/zone/*"
  - "DELETE /domain/zone/*"

And click `Create keys`.

You will be given an Application Key, an Application Secret and a Consumer Key. Keep those secret and safe as you
cannot retrieve them.

Update `settings.yml` and add the following values:
```yaml
pinanas:
  network:
    dns:
      provider:
        name: "ovh"
        email: "john.doe@example.com"
        api:
        - name: "OVH_APPLICATION_KEY"
          value: "<Your Application Key>"
        - name: "OVH_APPLICATION_SECRET"
          value: "<Your Application Secret>"
        - name: "OVH_CONSUMER_KEY"
          value: "<Your Consumer Key>"
        - name: "OVH_ENDPOINT"
          value: "<Your OVH zone, e.g. ovh-eu>"
```
