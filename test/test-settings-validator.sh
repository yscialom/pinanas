#!/bin/bash
set -e

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
node[last_field] = value
print(yaml.dump(settings, default_flow_style=False, sort_keys=False))
EOF
    chmod +x -- "${SCRIPT_FILE}"
}

#
## === check() ===
#
function check () {
    local path="${1}"
    local value="${2}"
    local expected="${3}"

    local settings_validator="$(readlink -f ${TEST_DIR}/../src/utils/settings-validator)"

    "${SCRIPT_FILE}" "${path}" "${value}" >"${SETTINGS_FILE}"

    set +e
    "${settings_validator}/validate.py" --quiet --schema "${settings_validator}/schema.json" --yaml-document "${SETTINGS_FILE}"
    if [[ $? == 0 ]] ; then local actual=valid ; else local actual=invalid ; fi
    set -e

    test_field "'${path} = \"${value}\"'" "settings.yaml validation" ${actual} ${expected}
}

#
## === ENTRY POINT ===
#
prepare

check "pinanas/domain" "example.com"                valid
check "pinanas/domain" "home-18.example.com"        valid
check "pinanas/domain" ""                           invalid
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

check "pinanas/master_secret" ""                                        valid
check "pinanas/master_secret" "s3cr3t"                                  valid
check "pinanas/master_secret" "azAZ09 /*-+&~#'([{|\`\\^@])}=$%!:;,?."   valid
check "pinanas/master_secret" "$(head -c 100 </dev/random | base64)"    valid

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

check "pinanas/users" '[{ "login": "johndoe", "password": "azAZ09 /*-+&~#([{|\\`^@])}=$%!:;,?.", "email": "john-john.doe+label@gmail.com" }]'   valid
check "pinanas/users" '[{ "login": "johndoe", "password": "qwerty", "fullname": "John Doe (JDO)", "email": "john-john.doe+label@gmail.com" }, \
                        { "login": "janedo", "password": "azerty", "email": "jane@do.it" }]'                                                    valid
check "pinanas/users" '[]'                                                                                                                      valid
check "pinanas/users" '{ "login": "janedo", "password": "azerty", "email": "jane@do.it" }'                                                      invalid
check "pinanas/users" '[{ "login": "janedo", "password": "azerty" }]'                                                                           invalid
check "pinanas/users" '[{ "login": "janedo", "email": "jane@do.it"" }]'                                                                         invalid
check "pinanas/users" '[{ "password": "azerty", "email": "jane@do.it" }]'                                                                       invalid
