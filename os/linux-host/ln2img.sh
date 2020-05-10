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
    echo "ln2img.sh image source destination"
    echo ""
    echo "In an image file, creates a symbolic link from source to destination."
    echo "source must be an absolute path from the root of the image partition."

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
ln -s ${source} ${tmpdir}/${destination}

# unmount
umount ${tmpdir}
