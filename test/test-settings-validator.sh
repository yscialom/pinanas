#!/bin/bash
set -e

TEST_DIR="$(dirname "$(readlink -f "$0")")"
DIST_DIR="$(readlink -f "${1}")"
TMP_FILE="$(mktemp)"
trap "rm -f -- ${TMP_FILE}" EXIT

source "${TEST_DIR}/web-functions.sh"
source "${DIST_DIR}/.venv/bin/activate"

function validate_schema () {
    local patch="${1}"
    local settings_validator="$(readlink -f ${TEST_DIR}/../src/utils/settings-validator)"
    patch --quiet --output="${TMP_FILE}" "${TEST_DIR}/settings.yaml.d/ci.yaml" "${patch}"
    "${settings_validator}/validate.py" --quiet --schema "${settings_validator}/schema.json" --yaml-document "${TMP_FILE}"
}

function check () {
    local patch="${1}"
    local expected=${2}

    set +e
    validate_schema "${patch}"
    local actual=$?
    set -e

    local patchname=$(basename ${patch%.*})
    local path=$(echo ${patchname%-*} | tr . /)
    local reason=$(echo ${patchname##*-})
    local explanation="field: ${path}, test: ${reason}"
    test_field "${explanation}" "${patch}" ${actual} ${expected}
}

check "${TEST_DIR}/settings.yaml.d/pinanas.domain-empty.patch" 1
