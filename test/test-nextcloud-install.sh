#!/bin/bash
set -e

TEST_DIR="$(dirname "$(readlink -f "$0")")"
DIST_DIR="$(readlink -f "${1}")"
source "${TEST_DIR}/web-functions.sh"

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

eval $(parse_yaml ${DIST_DIR}/settings.yaml "SETTINGS_")

domain="$SETTINGS_pinanas_domain"
if [ $SETTINGS_pinanas_ports_https != 443 ]; then https_port=":$SETTINGS_pinanas_ports_https"; else https_port=""; fi 
authelia="auth.${domain}${https_port}"
nextcloud="cloud.${domain}${https_port}"

function cmd () {
    local user="${1}" ; shift
    docker exec -u "${user}" nextcloud "$@"
}

function occ () {
    cmd $(id -u) /config/www/nextcloud/occ "$@"
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

function test_nextcloud_api () {
    # Generate application password for admin acount
    local admin_username=admin # set in src/templates/nextcloud/build/config/custom-cont-init.d/10-install-nextcloud.sh.j2
    local credentials="${admin_username}:$(docker exec -u $(id -u) -e NC_PASS=ignored nextcloud /config/www/nextcloud/occ user:add-app-password --password-from-env ${admin_username} | tail -1)"

    # Check Nextcloud status
    local url="https://${nextcloud}/ocs/v2.php/cloud/users/${admin_username}"
    api_expect "${url}" -u "${credentials}" -h "OCS-APIRequest: true" -q '.ocs.data.backend=="Database"'
}

function test_oidc () {
    local expected_discovery_endpoint="https://${authelia}/.well-known/openid-configuration"
    local actual_discovery_endpoint=$(occ user_oidc:provider --output=json --ansi \
        | jq -r '.[] | select(.identifier=="Authelia") .discoveryEndpoint' \
        || true )
    test_field "url" "openid connect" "${actual_discovery_endpoint}" "${expected_discovery_endpoint}"
}

function test_cron () {
    function croncount () {
        pattern="${1}"
        cmd 0 crontab -l | grep -Ec "${pattern}"
    }
    test_field "cron:files:scan" "crontab -l" $(croncount "files:scan --all") 1
}

test_install
test_nextcloud_api
test_oidc
test_cron
