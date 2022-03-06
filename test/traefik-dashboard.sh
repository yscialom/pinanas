#!/bin/bash

TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/web-functions.sh"

domain="pinanas-ci.scialom.org"
traefik="traefik-dashboard.${domain}"
https_port=42443

# http -> https
web_expect "http://${traefik}"  -c 302 -r "https://${traefik}/"
web_expect "https://${traefik}:${https_port}" -c 302 -r "https://${traefik}/dashboard/"
web_expect "https://${traefik}:${https_port}/dashboard/" -c 200

# api
api_expect "https://${traefik}:${https_port}/" -l 13
