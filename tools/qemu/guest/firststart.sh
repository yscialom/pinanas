#!/bin/bash

set -e

# Resize the filesystem to enjoy the full devise size
/opt/resizefs.sh
rm -f -- /opt/resizefs.sh

# Cleanup
function rmall () {
    local file="$(readlink -f ${1})"
    
    for link in $(find /etc -type l) ; do
        path=$(readlink -f "${link}")
        if [[ "${path}" == "${file}" ]]
        then rm -f -- "${link}"
        fi
    done
    rm -f -- "${file}"
}
rmall $0
