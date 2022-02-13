#!/bin/bash

TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/web-functions.sh"

domain="pinanas-ci.scialom.org"

docker run --rm curlimages/curl:7.77.0 -v "http://traefik-dashboard.${domain}"
web_expect "http://traefik-dashboard.${domain}" -c 302 -H "Location: https://traefik-dashboard.${domain}/"
