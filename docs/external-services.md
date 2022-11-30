Serve External Services
======================

What is an External Service?
---------------------------

An external service is simply any service not natively served by PiNanas that you choose to serve _through_ PiNanas. As of today, this is limited to HTTP and HTTPS services but could be extended.


Why should I serve it through PiNanas?
-------------------------------------

Serving a service through PiNanas as an external service offers many advantages:
- A **dedicated subdomain** to your service, to better fit in PiNanas environment.
- Your service **served through HTTPS**, with a valid TLS certificate.
- The full protection and monitoring offered by a **professional reverse-proxy**.
- **Authentification**: only known users can access your external service.
- If desired, a way to **serve your local service on the Internet**.


How to?
-------

In your `settings.yml` file (see [INSTALL](INSTALL.md#settings "docs/INSTALL.md") for more information), you will find
the variable `services`. You need to fill in the details for your provider. It is composed of two fields:
- The `name` (or code) of your service: this will be the subdomain your service will be available at;
- The internal `url` of your service: this is the url used locally (from the PiNanas server point of view) to access
  the service. It can be part of your own infrastructure of completely external.
```yaml
pinanas:
  services:
    - name: "servicecode1"
      url: "http://192.168.0.42:137"
    - name: "servicecode2"
      url: "https://www.example.net/application"
    - ...
```
This configuration will make both `servicecode1.example.com` and `servicecode2.example.com` available, protected by a valid TLS certificate and proxied and monitored by PiNanas.
