#!/bin/bash

TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/web-functions.sh"

domain="pinanas-ci.scialom.org"
traefik="traefik-dashboard.${domain}"

until web_expect -s "http://${traefik}" -c 302 ; do
    echo "$0: debug: status=$?"
    sleep 10
done
