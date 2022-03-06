#!/bin/bash

TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/web-functions.sh"

domain="pinanas-ci.scialom.org"
traefik="traefik-dashboard.${domain}"

until web_expect "https://${traefik}/" -s -c 302 ; do
    info "Waiting for traefik to start..."
    sleep 10
done
