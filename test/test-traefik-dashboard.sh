#!/bin/bash
set -e

TEST_DIR="$(dirname "$(readlink -f "$0")")"
DIST_DIR="$(readlink -f "${1}")"
source "${TEST_DIR}/web-functions.sh"

domain="pinanas-ci.scialom.org"
traefik_unsecure="traefik-dashboard.${domain}:8080"
traefik_secure="traefik-dashboard.${domain}:8443"

# setup external services
trap "docker stop pinanas-ci-ext-services && docker rmi httpd:2-alpine" EXIT
docker run \
  -d --rm --name pinanas-ci-ext-services \
  --network "$(basename ${DIST_DIR})_pinanas" \
  -l "traefik.enable=true" \
  -l "traefik.http.services.ext1.loadbalancer.server.port=80" \
  -l "traefik.http.services.ext2.loadbalancer.server.port=80" \
  -l "traefik.http.services.ext3.loadbalancer.server.port=80" \
  -l "traefik.http.services.ext4.loadbalancer.server.port=80" \
  httpd:2-alpine
sleep 10

# http -> https
web_expect "http://${traefik_unsecure}"  -c 301 -r "https://${traefik_secure}/"
web_expect "https://${traefik_secure}" -c 302 -r "https://${traefik_secure}/dashboard/"
web_expect "https://${traefik_secure}/dashboard/" -c 200

# api
api_expect "https://${traefik_secure}/api/overview" -q '.http.services.total==17'
api_expect "https://${traefik_secure}/api/overview" -q '.http.middlewares.total==15'
api_expect "https://${traefik_secure}/api/overview" -q '.http.routers.total==22'
api_expect "https://${traefik_secure}/api/overview" -q '.udp.routers.total==1'
api_expect "https://${traefik_secure}/api/overview" -q '.udp.services.total==1'
for entity in .{http,udp,tcp}.{services,middlewares,routers} ; do
    api_expect "https://${traefik_secure}/api/overview" -q "${entity}.warnings==0 and ${entity}.errors==0"
done

# external services
web_expect "http://ext1.${domain}" -c 301 -r "https://ext1.${domain}/"
html_expect "https://ext1.${domain}/" -r '<html><body><h1>It works!</h1></body></html>'
for sid in $(seq 2 4) ; do
    web_expect "http://ext${sid}.${domain}" -c 301 -r "https://ext${sid}.${domain}/"
    html_expect "https://ext${sid}.${domain}/" -r '<title>Login - Authelia</title>'
done
