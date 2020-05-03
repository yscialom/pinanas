#!/bin/bash

#
## === USAGE ===
#
function usage () {
    local status=${1}
    local message=${2}

    if [[ "${message}" != "" ]]
    then echo "$0: ${message}" >&2
    fi

    echo "USAGE"
    echo ""
    echo "installfirststart.sh image guest_dir"
    echo ""
    echo "Install a firststart script to the image"

    exit ${status}
}

if [[ $1 == "-h" ]]
then usage 0
fi


#
## === Checks ===
#
# This needs 3 arguments
if [[ $# != 2 ]]
then usage 1 "expecting 2 arguments"
fi

# This scripts needs superuser permissions.
if [[ ${EUID} != 0 ]] ; then
    usage 2 "error: must be run as super user."
fi


#
## === DATA ===
#
image=${1}
guestdir=${2}
linuxdir=$(dirname $(readlink -f $0))


#
## === ENTRYPOINT ===
#
for script in resizefs set-iptables-legacy install-dependencies ; do
    ${linuxdir}/cp2img.sh ${image} ${guestdir}/${script}.sh /opt/.
done

${linuxdir}/cp2img.sh ${image} ${guestdir}/firststart.sh /etc/init.d/nas-firststart
${linuxdir}/ln2img.sh ${image} /etc/init.d/nas-firststart /etc/rc3.d/S99nas-firststart
