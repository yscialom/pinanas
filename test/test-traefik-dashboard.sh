#!/bin/bash
set -e

TEST_DIR="$(dirname "$(readlink -f "$0")")"
DIST_DIR="$(readlink -f "${1}")"
source "${TEST_DIR}/web-functions.sh"
source "${TEST_DIR}/import-settings.sh" "${DIST_DIR}/settings.yaml"

traefik_http="traefik-dashboard.${pinanas_domain}${http_port}"
traefik_https="traefik-dashboard.${pinanas_domain}${https_port}"

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
web_expect "http://${traefik_http}" -c 301 -r "https://${traefik_https}/"
web_expect "https://${traefik_https}" -c 302 -r "https://${traefik_https}/dashboard/"
web_expect "https://${traefik_https}/dashboard/" -c 200

# api
api_expect "https://${traefik_https}/api/overview" -q '.http.services.total==18'
api_expect "https://${traefik_https}/api/overview" -q '.http.middlewares.total==16'
api_expect "https://${traefik_https}/api/overview" -q '.http.routers.total==24'
api_expect "https://${traefik_https}/api/overview" -q '.udp.routers.total==1'
api_expect "https://${traefik_https}/api/overview" -q '.udp.services.total==1'
for entity in .{http,udp,tcp}.{services,middlewares,routers} ; do
    api_expect "https://${traefik_https}/api/overview" -q "${entity}.warnings==0 and ${entity}.errors==0"
done

# external services
web_expect "http://ext1.${pinanas_domain}${http_port}" -c 301 -r "https://ext1.${pinanas_domain}${https_port}/"
html_expect "https://ext1.${pinanas_domain}${https_port}/" -r '<html><body><h1>It works!</h1></body></html>'
for sid in $(seq 2 4) ; do
    web_expect "http://ext${sid}.${pinanas_domain}${http_port}" -c 301 -r "https://ext${sid}.${pinanas_domain}${https_port}/"
    html_expect "https://ext${sid}.${pinanas_domain}${https_port}/" -r '<title>Login - Authelia</title>'
done
