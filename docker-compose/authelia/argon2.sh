#!/bin/bash

function usage () {
    if [[ -n ${2} ]] ; then
	echo "$(basename "${0}"): ${2}" >&2
    fi

    echo "USAGE -h | --help | $(basename "${0}") password"
    echo "  Cipher password for authelia"
    exit ${1}
}

function main() {
    local password="${1}"
    docker run authelia/authelia:4 authelia hash-password "${password}"
}

if [[ $# != 1 ]] ; then
    usage 1 "expected exactly one argument"
fi

case "${1}" in
    "-h"|"--help") usage 0 ;;
    *) main "${1}"
esac
