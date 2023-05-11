#!/bin/bash
TEST_DIR="$(dirname "$(readlink -f "$0")")"
DIST_DIR="$(readlink -f "${1}")"

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
if [ "$SETTINGS_pinanas_ports_http" != "80" ]; then http_port=":$SETTINGS_pinanas_ports_http"; else http_port=""; fi
if [ "$SETTINGS_pinanas_ports_https" != "443" ]; then https_port=":$SETTINGS_pinanas_ports_https"; else https_port=""; fi 
