#!/bin/bash

TEST_DIR="$(dirname "$(readlink -f "$0")")"
DIST_DIR="$(readlink -f "${1}")"
SCRIPT_FILE="$(mktemp --suffix .py)"
SETTINGS_FILE="$(mktemp)"
trap "rm -f -- ${SCRIPT_FILE} ${SETTINGS_FILE}" EXIT

source "${TEST_DIR}/web-functions.sh"
source "${DIST_DIR}/.venv/bin/activate"

#
## === prepare() ===
#
function prepare () {
    cat >"${SCRIPT_FILE}" <<EOF
#!/usr/bin/env python3
import sys
import yaml
import json

with open("${DIST_DIR}/settings.yaml") as f:
    settings = yaml.safe_load(f)

fields = sys.argv[1].split('/')
last_field = fields[-1]
try:
    value = json.loads(sys.argv[2])
except json.decoder.JSONDecodeError:
    value = sys.argv[2]
node = settings
for field in fields[:-1]:
    node = node.setdefault(field, dict())
if value is None:
    del node[last_field]
else:
    node[last_field] = value
print(yaml.dump(settings, default_flow_style=False, sort_keys=False))
EOF
    chmod +x -- "${SCRIPT_FILE}"
}

#
## === check() ===
#
check_result=0
function check () {
    local path="${1}"
    local value="${2}"
    local expected="${3}"

    local settings_validator="$(readlink -f ${TEST_DIR}/../src/utils/settings-validator)"

    "${SCRIPT_FILE}" "${path}" "${value}" >"${SETTINGS_FILE}"

    "${settings_validator}/validate.py" --quiet --schema "${settings_validator}/schema.json" --yaml-document "${SETTINGS_FILE}"
    if [[ $? == 0 ]] ; then local actual=valid ; else local actual=invalid ; fi

    test_field "'${path} = \"${value}\"'" "settings.yaml validation" ${actual} ${expected}
    local error_code=$?
    if [[ ${error_code} != 0 ]] ; then
        if [[ "${actual}" == "invalid" ]] ; then
            "${settings_validator}/validate.py" --schema "${settings_validator}/schema.json" --yaml-document "${SETTINGS_FILE}"
        fi
        check_result=${error_code}
    fi
}

#
## === ENTRY POINT ===
#
prepare

check "pinanas/domain" null                         invalid
check "pinanas/domain" ""                           invalid
check "pinanas/domain" "{}"                         invalid
check "pinanas/domain" "[]"                         invalid
check "pinanas/domain" "example.com"                valid
check "pinanas/domain" "home-18.example.com"        valid
check "pinanas/domain" "example/com"                invalid

check "pinanas/ports/http" 1                        valid
check "pinanas/ports/http" 65535                    valid
check "pinanas/ports/http" -1                       invalid
check "pinanas/ports/http" 0                        invalid
check "pinanas/ports/http" 65536                    invalid
check "pinanas/ports/http" http                     invalid

check "pinanas/ports/https" 1                       valid
check "pinanas/ports/https" 65535                   valid
check "pinanas/ports/https" -1                      invalid
check "pinanas/ports/https" 0                       invalid
check "pinanas/ports/https" 65536                   invalid
check "pinanas/ports/https" http                    invalid

check "pinanas/master_secret" null                                      invalid
check "pinanas/master_secret" ""                                        valid
check "pinanas/master_secret" "{}"                                      invalid
check "pinanas/master_secret" "[]"                                      invalid
check "pinanas/master_secret" "s3cr3t"                                  valid
check "pinanas/master_secret" "azAZ09 /*-+&~#'([{|\`\\^@])}=$%!:;,?."   valid
check "pinanas/master_secret" "$(head -c 100 </dev/random | base64)"    valid

check "pinanas/timezone" null                       invalid
check "pinanas/timezone" ""                         invalid
check "pinanas/timezone" "{}"                       invalid
check "pinanas/timezone" "[]"                       invalid
check "pinanas/timezone" "Europe/Paris"             valid
check "pinanas/timezone" "America/Louisville"       valid
check "pinanas/timezone" "US/Samoa"                 valid
check "pinanas/timezone" "Kwajalein"                valid
check "pinanas/timezone" "Europe/Stockholm"         valid
check "pinanas/timezone" "Asia/Makassar"            valid
check "pinanas/timezone" "Africa/Ouagadougou"       valid
check "pinanas/timezone" "America/Porto_Velho"      valid
check "pinanas/timezone" "America/Merida"           valid
check "pinanas/timezone" "Europe/Busingen"          valid
check "pinanas/timezone" "Antarctica/Vostok"        valid
check "pinanas/timezone" "Europe/Kiev"              valid
check "pinanas/timezone" "CET"                      valid
check "pinanas/timezone" "Etc/GMT+12"               valid
check "pinanas/timezone" "Etc/GMT-14"               valid
check "pinanas/timezone" "Etc/GMT+0"                valid
check "pinanas/timezone" "Etc/GMT-0"                valid
check "pinanas/timezone" "Etc/UTC"                  valid
check "pinanas/timezone" "Etc/Zulu"                 valid
check "pinanas/timezone" "Europe/Mont_Saint_Michel" invalid
check "pinanas/timezone" "Asia/New_York"            invalid
check "pinanas/timezone" 42                         invalid

check "pinanas/users" null                                                                                                                      invalid
check "pinanas/users" '{}'                                                                                                                      invalid
check "pinanas/users" '[]'                                                                                                                      invalid
check "pinanas/users" '[{ "login": "johndoe", "password": "azAZ09 /*-+&~#([{|\\`^@])}=$%!:;,?.", "email": "john-john.doe+label@gmail.com" }]'   valid
check "pinanas/users" '[{ "login": "johndoe", "password": "qwerty", "fullname": "John Doe (JDO)", "email": "john-john.doe+label@gmail.com" }, { "login": "janedo", "password": "azerty", "email": "jane@do.it" }]' \
                                                                                                                                                valid
check "pinanas/users" '{ "login": "janedo", "password": "azerty", "email": "jane@do.it" }'                                                      invalid
check "pinanas/users" '[{ "login": "janedo", "password": "azerty" }]'                                                                           invalid
check "pinanas/users" '[{ "login": "janedo", "email": "jane@do.it"" }]'                                                                         invalid
check "pinanas/users" '[{ "password": "azerty", "email": "jane@do.it" }]'                                                                       invalid

check "pinanas/services" null                                                                           valid
check "pinanas/services" '{}'                                                                           invalid
check "pinanas/services" '[]'                                                                           valid
check "pinanas/services" '[{ "name": "somename" }]'                                                     valid
check "pinanas/services" '[{ "name": "somename", "url": "http://example.com" }]'                        valid
check "pinanas/services" '[{ "name": "somename", "url": "https://127.0.0.1" }]'                         valid
check "pinanas/services" '[{ "name": "somename", "policy": "bypass" }]'                                 valid
check "pinanas/services" '[{ "name": "somename1" }, { "name": "somename2" }]'                           valid
check "pinanas/services" '{ "name": "somename" }'                                                       invalid
check "pinanas/services" '[{ "policy": "bypass" }]'                                                     invalid
check "pinanas/services" '[{ "name": "somename1" }, { "name": "somename2" }, { "policy": "bypass" }]'   invalid
check "pinanas/services" '[{ "name": "somename", "policy": "does_not_exist" }]'                         invalid

check "pinanas/acme" null                       valid
check "pinanas/acme" '{}'                       invalid
check "pinanas/acme" '[]'                       invalid
check "pinanas/acme" '{ "stagging": true }'     valid
check "pinanas/acme" '{ "stagging": false }'    valid
check "pinanas/acme" '{ "stagging": 0 }'        invalid
check "pinanas/acme" '{ "stagging": "true" }'   invalid

check "pinanas/network/dhcp" null valid

check "pinanas/network/dhcp/hmac" ''                        invalid
check "pinanas/network/dhcp/hmac" '{}'                      invalid
check "pinanas/network/dhcp/hmac" '[]'                      invalid
check "pinanas/network/dhcp/hmac" '01:23:45:67:89:ab'       valid
check "pinanas/network/dhcp/hmac" 'cd:ef:AB:CD:EF:00'       valid
check "pinanas/network/dhcp/hmac" '01:23:45:67:89'          invalid
check "pinanas/network/dhcp/hmac" '01:23:45:67:89:ab:'      invalid
check "pinanas/network/dhcp/hmac" '01:23:45:67:89:ab:cd'    invalid
check "pinanas/network/dhcp/hmac" '01,23,45,67,89,ab'       invalid
check "pinanas/network/dhcp/hmac" '01f23f45f67f89fab'       invalid

check "pinanas/network/dhcp/ip" ''                          invalid
check "pinanas/network/dhcp/ip" '{}'                        invalid
check "pinanas/network/dhcp/ip" '[]'                        invalid
check "pinanas/network/dhcp/ip" '0.0.0.0'                   valid
check "pinanas/network/dhcp/ip" '254.254.254.254'           valid
check "pinanas/network/dhcp/ip" '254,254,254,254'           invalid
check "pinanas/network/dhcp/ip" '254254254254...'           invalid
check "pinanas/network/dhcp/ip" '254 254 254 254'           invalid

check "pinanas/network/dhcp/base" ''                        invalid
check "pinanas/network/dhcp/base" '{}'                      invalid
check "pinanas/network/dhcp/base" '[]'                      invalid
check "pinanas/network/dhcp/base" '0.0.0.0'                 valid
check "pinanas/network/dhcp/base" '254.254.254.254'         valid
check "pinanas/network/dhcp/base" '254,254,254,254'         invalid
check "pinanas/network/dhcp/base" '254254254254...'         invalid
check "pinanas/network/dhcp/base" '254 254 254 254'         invalid

check "pinanas/network/dhcp/subnet" ''                      invalid
check "pinanas/network/dhcp/subnet" '{}'                    invalid
check "pinanas/network/dhcp/subnet" '[]'                    invalid
check "pinanas/network/dhcp/subnet" '0.0.0.0'               valid
check "pinanas/network/dhcp/subnet" '254.254.254.254'       valid
check "pinanas/network/dhcp/subnet" '254,254,254,254'       invalid
check "pinanas/network/dhcp/subnet" '254254254254...'       invalid
check "pinanas/network/dhcp/subnet" '254 254 254 254'       invalid

check "pinanas/network/dhcp/gateway" ''                     invalid
check "pinanas/network/dhcp/gateway" '{}'                   invalid
check "pinanas/network/dhcp/gateway" '[]'                   invalid
check "pinanas/network/dhcp/gateway" '0.0.0.0'              valid
check "pinanas/network/dhcp/gateway" '254.254.254.254'      valid
check "pinanas/network/dhcp/gateway" '254,254,254,254'      invalid
check "pinanas/network/dhcp/gateway" '254254254254...'      invalid
check "pinanas/network/dhcp/gateway" '254 254 254 254'      invalid

check "pinanas/network/dhcp/range" null                                         valid
check "pinanas/network/dhcp/range" ''                                           invalid
check "pinanas/network/dhcp/range" '{}'                                         valid
check "pinanas/network/dhcp/range" '[]'                                         invalid
check "pinanas/network/dhcp/range" '{ "start": "0.0.0.0", "end": "0.0.0.0" }'   valid
check "pinanas/network/dhcp/range" '{ "start": "0.0.0.0" }'                     valid
check "pinanas/network/dhcp/range" '{ "end": "0.0.0.0" }'                       valid

check "pinanas/network/dhcp/fixed_address_leases" null                                                                          valid
check "pinanas/network/dhcp/fixed_address_leases" ''                                                                            invalid
check "pinanas/network/dhcp/fixed_address_leases" '{}'                                                                          invalid
check "pinanas/network/dhcp/fixed_address_leases" '[]'                                                                          valid
check "pinanas/network/dhcp/fixed_address_leases" '[{ "name": "somename", "hmac": "01:23:45:67:89:ab", "ip": "0.0.0.0" }]'      valid
check "pinanas/network/dhcp/fixed_address_leases" '[{ "name": "somename", "hmac": "01:23:45:67:89:ab" }]'                       invalid
check "pinanas/network/dhcp/fixed_address_leases" '[{ "name": "somename", "ip": "0.0.0.0" }]'                                   invalid
check "pinanas/network/dhcp/fixed_address_leases" '[{ "hmac": "01:23:45:67:89:ab", "ip": "0.0.0.0" }]'                          invalid
check "pinanas/network/dhcp/fixed_address_leases" '[{ "name": "somename1", "hmac": "01:23:45:67:89:ab", "ip": "0.0.0.0" }, { "name": "somename2", "hmac": "01:23:45:67:89:ab", "ip": "0.0.0.0" }]' \
                                                                                                                                valid
check "pinanas/network/dns" null                        invalid
check "pinanas/network/dns" ''                          invalid
check "pinanas/network/dns" '{}'                        invalid
check "pinanas/network/dns" '[]'                        invalid
check "pinanas/network/dns" '{ "upstream": "0.0.0.0" }' invalid

check "pinanas/network/dns/upstream" ''                                 invalid
check "pinanas/network/dns/upstream" '{}'                               invalid
check "pinanas/network/dns/upstream" '[]'                               valid
check "pinanas/network/dns/upstream" '[ "0.0.0.0" ]'                    valid
check "pinanas/network/dns/upstream" '[ "0.0.0.0", "255.255.255.255" ]' valid
check "pinanas/network/dns/upstream" '[ "0.0.0.0", "localhost" ]'       valid

check "pinanas/network/dns/provider" null                                                           invalid
check "pinanas/network/dns/provider" ''                                                             invalid
check "pinanas/network/dns/provider" '{}'                                                           invalid
check "pinanas/network/dns/provider" '[]'                                                           invalid
check "pinanas/network/dns/provider" '{ "name": "somename", "email": "jd@gmail.com", "api": [] }'   valid
check "pinanas/network/dns/provider" '{ "name": "somename", "email": "jd@gmail.com" }'              invalid
check "pinanas/network/dns/provider" '{ "name": "somename", "api": [] }'                            invalid
check "pinanas/network/dns/provider" '{ "email": "jd@gmail.com", "api": [] }'                       invalid

check "pinanas/network/dns/provider/email" ''                   invalid
check "pinanas/network/dns/provider/email" '{}'                 invalid
check "pinanas/network/dns/provider/email" '[]'                 invalid
check "pinanas/network/dns/provider/email" 'john-doe@mail.com'  valid
check "pinanas/network/dns/provider/email" 'jane@do.it'         valid
check "pinanas/network/dns/provider/email" 'jane at do.it'      invalid

check "pinanas/network/dns/provider/api" ''                                                                 invalid
check "pinanas/network/dns/provider/api" '{}'                                                               invalid
check "pinanas/network/dns/provider/api" '[]'                                                               valid
check "pinanas/network/dns/provider/api" '[{ "name": "k", "value": "v" }]'                                  valid
check "pinanas/network/dns/provider/api" '[{ "name": "k" }]'                                                invalid
check "pinanas/network/dns/provider/api" '[{ "value": "v" }]'                                               invalid
check "pinanas/network/dns/provider/api" '[{ "name": "k1", "value": "v" }, { "name": "k2", "value": "v" }]' valid

check "pinanas/network/smtp" null   invalid
check "pinanas/network/smtp" ''     invalid
check "pinanas/network/smtp" '{}'   invalid
check "pinanas/network/smtp" '[]'   invalid

check "pinanas/network/smtp/host" null      invalid
check "pinanas/network/smtp/port" null      invalid
check "pinanas/network/smtp/port" ''        invalid
check "pinanas/network/smtp/port" 0         invalid
check "pinanas/network/smtp/port" 1         valid
check "pinanas/network/smtp/port" 65535     valid
check "pinanas/network/smtp/port" 65536     invalid
check "pinanas/network/smtp/port" '"42"'    invalid
check "pinanas/network/smtp/username" null  invalid
check "pinanas/network/smtp/password" null  invalid
check "pinanas/network/smtp/sender" null    invalid

check "pinanas/applications" null                                               valid
check "pinanas/applications" ''                                                 invalid
check "pinanas/applications" '{}'                                               invalid
check "pinanas/applications" '[]'                                               valid
check "pinanas/applications" '[ "adguardhome" ]'                                valid
check "pinanas/applications" '[ "netdata", "adguardhome" ]'                     valid
check "pinanas/applications" '[ "netdata", "adguardhome", "doesnotexists" ]'    invalid

exit ${check_result}
