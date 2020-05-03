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
## === DATA ===
#
device=/dev/sda
boot=1
os=2
start=$(fdisk -l ${device} -o device,start \
            | grep -E ^${device}${os} \
            | awk '{print $2}')


#
## === Resize OS partition ===
#
# At this point, the device (physical or image file) is bigger
# than the default rasbian image, but the OS partition (which /
# is mounted on) is still to its default size. fdisl -l /dev/sda
# would show two small partitions. We need te resize /dev/sda2.
# To create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk.
# The sed script strips off all the comments so that we can
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${device}
  d        # delete
    ${os}    # OS partition
  n        # create new
    p        # primary partition
    ${os}    # partition number
    ${start} # starting exactly where the deleted OS parition started
             # default: maximum size
  a        # add boot flag
    ${os}    # to OS parition
  w        # write to disk
  q        # the end
EOF


#
## === Resize filesystem ===
#
# At that point, the partition which / is mounted on has been resized,
# but the filesystem itself is unchanged still. df would show a size of
# 2 or 3 GB. To fully enjoy all the space we added in the partition
# the filesystem needs to be resized and remounted.
resize2fs ${device}${os}
mount -o remount ${device}${os}
