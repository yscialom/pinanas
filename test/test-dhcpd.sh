#!/bin/bash
set -e

TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/web-functions.sh"

docker exec dhcpd dhcpd -t -cf /data/dhcpd.conf
