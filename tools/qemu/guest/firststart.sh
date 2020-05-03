#!/bin/bash

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

{ #start redirect group
    # Forbids (politly) to login
    trap "rm -f -- /run/nologin" EXIT
    touch /run/nologin

    # Resize the filesystem to enjoy the full devise size
    run-and-delete /opt/resizefs.sh

    # Set iptable to use legacy interface
    run-and-delete /opt/set-iptables-legacy.sh

    # Upgrade & install what's required
    run-and-delete /opt/install-dependencies.sh

    # Cleanup
    rmall $0

    # Reboot
    reboot
} > /var/log/firststart # redirect
