#!/bin/bash
set -e

TEST_DIR="$(dirname "$(readlink -f "$0")")"
DIST_DIR="$(readlink -f "${1}")"
source "${TEST_DIR}/web-functions.sh"

domain="pinanas-ci.scialom.org"
traefik="traefik-dashboard.${domain}"

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
web_expect "http://${traefik}"  -c 301 -r "https://${traefik}/"
web_expect "https://${traefik}" -c 302 -r "https://${traefik}/dashboard/"
web_expect "https://${traefik}/dashboard/" -c 200

# api
api_expect "https://${traefik}/api/overview" -q '.http.services.total==16'
api_expect "https://${traefik}/api/overview" -q '.http.middlewares.total==14'
api_expect "https://${traefik}/api/overview" -q '.http.routers.total==20'
api_expect "https://${traefik}/api/overview" -q '.udp.routers.total==1'
api_expect "https://${traefik}/api/overview" -q '.udp.services.total==1'
for entity in .{http,udp,tcp}.{services,middlewares,routers} ; do
    api_expect "https://${traefik}/api/overview" -q "${entity}.warnings==0 and ${entity}.errors==0"
done

# external services
web_expect "http://ext${sid}.${domain}" -c 301 -r "https://ext${sid}.${domain}/"
curl_ "https://ext1.${domain}/" | grep -q '<html><body><h1>It works!</h1></body></html>'
for sid in $(seq 2 4) ; do
    web_expect "http://ext${sid}.${domain}" -c 301 -r "https://ext${sid}.${domain}/"
    curl_ -L "https://ext${sid}.${domain}/" | grep -q '<title>Login - Authelia</title>'
done
