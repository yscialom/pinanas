#!/bin/bash

#
## === Checks ===
#
# This scripts needs superuser permissions.
if [[ ${EUID} != 0 ]] ; then
    echo "$0: error: must be run as super user." >&2
    exit 1
fi


#
## === Utils ===
#

function rmall () {
    local file="$(readlink -f ${1})"
    echo "deleting '${file}' and all links pointing to it"

    for link in $(find /etc/rc*.d -type l) ; do
        path=$(readlink -f "${link}")
        if [[ "${path}" == "${file}" ]] ; then
            echo "delete link '${link}' pointing to '${path}'"
            rm -f -- "${link}"
        fi
    done
    echo "delete '${file}'"
    rm -f -- "${file}"
}

function run-and-delete () {
    local script=${1}
    ${script}
    rm -f -- ${script}
}


#
## === Actions ===
#

{ #start redirect group
    set -x

    # Forbids (politly) to login
    trap "rm -f -- /run/nologin" EXIT
    touch /run/nologin

    # install scripts
    for script in resizefs setup-raspbian install-dependencies ; do
        run-and-delete /opt/${script}.sh
    done

    # Cleanup
    rmall $0

    # Reboot
    reboot
} > /var/log/firststart # redirect
