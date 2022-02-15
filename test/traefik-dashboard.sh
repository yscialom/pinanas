#!/bin/bash

TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/web-functions.sh"

domain="pinanas-ci.scialom.org"
traefik="traefik-dashboard.${domain}"

# http -> https
web_expect "http://${traefik}"  -c 302 -r "https://${traefik}/"
web_expect "httpd://${traefik}" -c 302 -r "https://${traefik}/dashboard/"
web_expect "httpd://${traefik}/dashboard/" -c 200

# api
api_expect "httpd://${traefik}/" -l 13
