Enabling and Disabling Applications
===================================

What is an Applications?
------------------------

An application is any service natively included with PiNanas (like DHCPD, Traefik, etc).
All applications are listed and detailled in [README](README.md#settings "README.md")

Why would I want to enable/disable some applications?
----------------------------------------------------

PiNanas has been designed to offer all applications "in the box" per default.
You can personalise this behaviour by selecting which applications you are interested in and want to enable.

How to?
-------

In your `settings.yaml` file (see [SETTINGS](INSTALL.md#settings "docs/INSTALLt.md") and
[APPLICATIONS](applications-list.md "docs/applications-list.md") for more information), add the variable
`applications`. In this variable, list all the application you want enabled. Other application will be disabled:
```yaml
pinanas:
  applications:
    - adguardhome
    - nextcloud
    - ...
```
