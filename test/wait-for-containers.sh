#!/bin/bash

TEST_DIR="$(dirname "$(readlink -f "$0")")"
source "${TEST_DIR}/web-functions.sh"

function wait_for_container {
    local container_name="${1}"
    local container_id="$(docker inspect "${container_name}" --format '{{ .Id }}')"
    info "Waiting for container ${container_name} (id: ${container_id})"
    local waiting_done="false"
    while [[ ${waiting_done} != "true" ]] ; do
        sleep ${sleep_time:-0}
        local container_state="$(docker inspect "${container_id}" --format '{{ .State.Status }}')"
        if [[ ${container_state} == "running" ]] ; then
            local health_available="$(docker inspect "${container_id}" --format '{{ .State.Health }}')"
            if [[ ${health_available} == "<nil>" ]] ; then
                waiting_done="true"
            else
                local health_status="$(docker inspect "${container_id}" --format '{{ .State.Health.Status }}')"
                cont "${container_name}: container_state=${container_state}, health_status=${health_status}"
                if [[ ${health_status} == "healthy" ]] ; then
                    waiting_done="true"
                fi
            fi
        else
            cont "${container_name}: container_state=${container_state}"
            waiting_done="true"
        fi
        local sleep_time=5 # secondes
    done
}

for service in $(docker-compose ps --services) ; do
    wait_for_container "${service}"
    [[ -x "${TEST_DIR}/wait-for-${service}.sh" ]] && "${TEST_DIR}/wait-for-${service}.sh"
done
