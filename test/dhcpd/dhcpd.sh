#!/bin/bash
DIST_DIR="$(readlink -f "${1}")"
TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/../web-functions.sh"

tag=dhcping:alpine
trap "docker image rm ${tag}" EXIT
docker build -t ${tag} "${TEST_DIR}"

docker run --rm --net=host ${tag} -s localhost -q
