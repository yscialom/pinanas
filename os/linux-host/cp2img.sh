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
    echo "cp2img.sh image source destination"
    echo ""
    echo "copies source to image at destination"

    exit ${status}
}

if [[ $1 == "-h" ]]
then usage 0
fi


#
## === Checks ===
#
# This needs 3 arguments
if [[ $# != 3 ]]
then usage 1 "expecting 3 arguments"
fi

# This scripts needs superuser permissions.
if [[ ${EUID} != 0 ]] ; then
    usage 2 "error: must be run as super user."
fi



#
## === DATA ===
#
device=${1}
source=${2}
destination=${3}

boot=1
os=2
sectorsize=512
sectorstart=$(fdisk -l ${device} -o device,start \
            | grep -E ^${device}${os} \
            | awk '{print $2}')
bytestart=$(expr ${sectorsize} \* ${sectorstart})

trap "rm -rf -- ${tmpdir}" EXIT
tmpdir=$(mktemp -d)


#
## === ENTRYPOINT ===
#

# mount
mount -o loop,offset=${bytestart} ${device} ${tmpdir}

# copy
cp ${source} ${tmpdir}/${destination}

# unmount
umount ${tmpdir}
