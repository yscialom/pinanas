@echo off

: Start an ARM emulated machine running Raspberrian on Windows (amd64)
:
: Usage
: =====
:
: ```cmd
: start-arm-start.bat
: ```
:
: Raspberrian default credentials
: -------------------------------
:
: - login: pi
: - password: raspberry
:
: Requierments
: ============
:
: Download and install tools
: --------------------------
: - download dtb file and kernel from <https://github.com/dhruvvyas90/qemu-rpi-kernel/>
: - download & unzip image file from raspberrian website <https://www.raspberrypi.org/downloads/raspbian/>
: - download & install qemu-system for windows from <https://qemu.weilnetz.de/w64/>
:
: Set the following variables from your system settings
: -----------------------------------------------------
: - DTB : fullpath to your DTD file
: - KERNEL : fullpath to your kernel file
: - IMAGE : fullpath to your image file
: - QEMU_DIR : directory containing qemu-system-arm.exe

: === START OF CONFIGURATION: EDIT AFTER THIS LINE ===
set "DTB=D:\...\versatile-pb.dtb" 
set "KERNEL=D:\...\kernel-qemu-4.19.50-buster"
set "IMAGE=D:\...\2020-02-13-raspbian-buster-lite.img"
set "QEMU_DIR=C:\Program Files\qemu"
: === END OF CONFIGURATION: DO NOT EDIT AFTER THIS LINE ===


set "PATH=%PATH%;%QEMU_DIR%"
qemu-system-arm ^
	-kernel "%KERNEL%" ^
	-append "root=/dev/sda2 rootfstype=ext4 rw" ^
	-hda "%IMAGE%" ^
	-cpu arm1176 -m 256 ^
    -M versatilepb -dtb "%DTB%" ^
	-no-reboot ^
	-serial stdio ^
	-nic user,hostfwd=tcp::5022-:22
