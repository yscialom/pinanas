#!/bin/bash

source web-functions.sh

domain="pinanas-ci.scialom.org"
web_expect "http://traefik-dashboard.${domain}" -c 302 -H "Location: https://traefik-dashboard.${domain}/"
