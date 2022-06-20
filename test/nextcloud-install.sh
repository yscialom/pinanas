#!/bin/bash
DIST_DIR="$(readlink -f "${1}")"

TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/web-functions.sh"

domain="pinanas-ci.scialom.org"
authelia="auth.${domain}"

function occ () {
    docker exec -u1000 nextcloud /config/www/nextcloud/occ "$@"
}

function test_install () {
    function command_field () {
        local fieldname="${1}" ; shift
        local command="${@}"
        occ ${command} | sed -n 's/ *- '"${fieldname}"': *\([0-9a-zA-Z._-]\+\)\r\?$/\1/p'
    }

    local expected_nextcloud_version=$(sed -n 's/^FROM .*nextcloud:\([0-9.]\+\)$/\1/p' "${DIST_DIR}/nextcloud/build/Dockerfile")
    test_field "installed"   "occ status" "$(command_field installed     status)" "true"
    test_field "version"     "occ status" "$(command_field versionstring status)" "${expected_nextcloud_version}"
    test_field "maintenance" "occ status" "$(command_field maintenance   status)" "false"
    test_field "admin"       "occ user:info admin" "$(command_field enabled user:info admin)" "true"
}

function test_oidc () {
    local expected_discovery_endpoint="https://${authelia}/.well-known/openid-configuration"
    local actual_discovery_endpoint=$(occ user_oidc:provider --output=json --ansi \
        | jq -r '.[] | select(.identifier=="Authelia") .discoveryEndpoint' \
        || true )
        test_field "openid connect" "${actual_discovery_endpoint}" "${expected_discovery_endpoint}"
}

test_install
test_oidc