#!/bin/bash

TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/web-functions.sh"

function wait-for-nextcloud () {
    local waiting_done="false"
    while [[ ${waiting_done} != "true" ]] ; do
        [[ -f nextcloud/data/generated-config/installed ]] && waiting_done="true"
        sleep 5
    done
}

wait-for-nextcloud
