#
# Reads a PiNanas settings file and define bash variable accordingly.
#
# Usage:
#     source ./import-settings.sh /path/to/settings.yaml
#
# Variable defined:
#     For each key 'pinanas.nested.key', defined the variable 'pinanas_nested_key'.
#     Also defines the convenient variables 'http_port' and 'https_port'.
##

function parse_yaml {
    local filepath="${1}"
    local prefix=${2}
    local delimiter=${3:'_'}

    local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
    sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" "${filepath}" \
    | awk -F$fs '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("'${delimiter}'")}
            printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
        }
    }'
}

eval $(parse_yaml "${1}")

[[ -v pinanas_ports_http ]] && [[ "${pinanas_ports_http}" != "80"  ]] && http_port=":${pinanas_ports_http}" || http_port=""
[[ -v pinanas_ports_https ]] && [[ "${pinanas_ports_https}" != "80"  ]] && https_port=":${pinanas_ports_https}" || https_port=""
