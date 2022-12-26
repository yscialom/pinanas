#!/bin/bash
set -e

TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/web-functions.sh"

domain="pinanas-ci.scialom.org"
traefik="traefik-dashboard.${domain}"

# setup external services
trap "docker stop pinanas-ci-ext-services && docker rmi httpd:2-alpine" EXIT
docker run \
  -d --rm --name pinanas-ci-ext-services -p 80:80 \
  -l "traefik.enable=true" \
  -l "traefik.http.routers.ext1.entrypoints=http" \
  -l "traefik.http.routers.ext1.rule=Host(`ext1.${domain}`)" \
  -l "traefik.http.routers.ext3.entrypoints=http" \
  -l "traefik.http.routers.ext3.rule=Host(`ext3.${domain}`)" \
  -l "traefik.http.routers.ext4.entrypoints=http" \
  -l "traefik.http.routers.ext4.rule=Host(`ext4.${domain}`)" \
  httpd:2-alpine
sleep 10

# http -> https
web_expect "http://${traefik}"  -c 301 -r "https://${traefik}/"
web_expect "https://${traefik}" -c 302 -r "https://${traefik}/dashboard/"
web_expect "https://${traefik}/dashboard/" -c 200

# api
api_expect "https://${traefik}/api/overview" -q '.http.services.total==13'
api_expect "https://${traefik}/api/overview" -q '.http.middlewares.total==14'
api_expect "https://${traefik}/api/overview" -q '.http.routers.total==20'
api_expect "https://${traefik}/api/overview" -q '.udp.routers.total==1'
api_expect "https://${traefik}/api/overview" -q '.udp.services.total==1'
for entity in .{http,udp,tcp}.{services,middlewares,routers} ; do
    api_expect "https://${traefik}/api/overview" -q "${entity}.warnings==0 and ${entity}.errors==0"
done
