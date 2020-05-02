#!/bin/bash

function cleanup () {
    rm -f -- raspbian.zip
    rm -rf -- qemu-rpi-kernel
}

trap cleanup EXIT

# raspi kernel
git clone --depth=1 git@github.com:dhruvvyas90/qemu-rpi-kernel.git
cp qemu-rpi-kernel/kernel-qemu-*-buster kernel
cp qemu-rpi-kernel/versatile-pb.dtb versatile-pb.dtb

# raspbian image
curl -pL https://downloads.raspberrypi.org/raspbian_latest --output raspbian.zip
unzip raspbian.zip
mv *-raspbian-*.img raspbian.img


