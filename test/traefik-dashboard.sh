#!/bin/bash
set -e

TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/web-functions.sh"

domain="pinanas-ci.scialom.org"
traefik="traefik-dashboard.${domain}"

# http -> https
web_expect "http://${traefik}"  -c 302 -r "https://${traefik}/"
web_expect "https://${traefik}" -c 302 -r "https://${traefik}/dashboard/"
web_expect "https://${traefik}/dashboard/" -c 200

#tmp
curl -s "https://${traefik}/api/http/services

# api
api_expect "https://${traefik}/api/overview" -q '.http.services.total==10'
api_expect "https://${traefik}/api/overview" -q '.http.middlewares.total==12'
api_expect "https://${traefik}/api/overview" -q '.http.routers.total==12'
api_expect "https://${traefik}/api/overview" -q '.udp.routers.total==1'
api_expect "https://${traefik}/api/overview" -q '.udp.services.total==1'
for entity in .{http,udp,tcp}.{services,middlewares,routers} do
    api_expect "https://${traefik}/api/overview" -q "${entity}.warnings==0 and ${entity}.errors==0"
done
