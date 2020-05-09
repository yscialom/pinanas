@echo off

: Convert & resize a fixed-size raw image to a qcow dynamic one
:
: Usage
: =====
:
: ```cmd
: start-image-convert.bat
: ```
:
: Requierments
: ============
:
: Download and install tools
: --------------------------
: - download & unzip image file from raspberrian website <https://www.raspberrypi.org/downloads/raspbian/>
: - download & install qemu for windows from <https://qemu.weilnetz.de/w64/>
:
: Set the following variables from your system settings
: -----------------------------------------------------
: - IMAGE : fullpath to your raw image file
: - OUTPUT_FILENAME : fullpath to your qcow image file
: - QEMU_DIR : directory containing qemu-system-arm.exe
: - SIZE : size of the emulated SD card

: === START OF CONFIGURATION: EDIT AFTER THIS LINE ===
set "IMAGE=D:\bin\vm\nas\2020-02-13-raspbian-buster-lite.img"
set "OUTPUT_FILENAME=D:\bin\vm\nas\2020-02-13-raspbian-buster-lite.qcow"
set "QEMU_DIR=C:\Program Files\qemu"
set SIZE=20G
: === END OF CONFIGURATION: DO NOT EDIT AFTER THIS LINE ===


set "PATH=%PATH%;%QEMU_DIR%"

qemu-img ^
	convert -p -f raw -O qcow2 ^
	"%IMAGE%" ^
	"%OUTPUT_FILENAME%" 
qemu-img ^
	resize "%OUTPUT_FILENAME%" ^
	%SIZE%
