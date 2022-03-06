#!/bin/bash

TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/web-functions.sh"

domain="pinanas-ci.scialom.org"
traefik="traefik-dashboard.${domain}"

# http -> https
web_expect "http://${traefik}"  -c 302 -r "https://${traefik}/"
web_expect "https://${traefik}" -c 302 -r "https://${traefik}/dashboard/"
web_expect "https://${traefik}/dashboard/" -c 200

# api
api_expect "https://${traefik}/api/http/routers" -l 12
api_expect "https://${traefik}/api/http/services" -l 10
api_expect "https://${traefik}/api/http/middlewares" -l 12
api_expect "https://${traefik}/api/udp/routers" -l 1
api_expect "https://${traefik}/api/udp/services" -l 1
