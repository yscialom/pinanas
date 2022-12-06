Enabling and Disabling Applications
===================================

What is an Applications?
------------------------

An application is any service natively include with PiNanas (like DHCPD, Traefik, etc).
All applications are listed and detailled in [README](README.md#settings "README.md")

Why would I want enable/disable some applications?
---------------------------------------------

PiNanas has been designed to propose all applications "in the box"
But, you have the possibility to personalise your PiNanas and so
you will want to be able to select the applications you are interested in.

How to?
-------

In your 'settings.yml' file (see [INSTALL](INSTALL.md#settings "docs/INSTALL.md") for more information), you will find
the variable 'applications'. This is where you can list applications you want (from the list of those availables).

```yaml
pinanas:
  applications:
    - adguardhome
    - nextcloud
    - ...
```
