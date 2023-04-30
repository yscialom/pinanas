#!/bin/bash
set -e

TEST_DIR="$(dirname "$(readlink -f "$0")")"
DIST_DIR="$(readlink -f "${1}")"
TMP_FILE="$(mktemp)"
trap "rm -f -- ${TMP_FILE}" EXIT

source "${TEST_DIR}/web-functions.sh"
source "${DIST_DIR}/.venv/bin/activate"

function validate () {
    local patch="${1}"
    local settings_validator="$(readlink -f ${TEST_DIR}/../src/utils/settings-validator)"
    patch --output="${TMP_FILE}" "${TEST_DIR}/settings.yaml.d/ci.yaml" "${patch}"
    "${settings_validator}/validate.py" -s "${settings_validator}/schema.json" -y "${TMP_FILE}"
}

validate "${TEST_DIR}/settings.yaml.d/pinanas.domain-empty.patch"
