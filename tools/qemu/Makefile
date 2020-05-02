Q=@
SCRIPTS=start
IMG_SIZE=20G
ALL=kernel versatile-pb.dtb rasbian.img qemu $(SCRIPTS)

all: $(ALL)

#
## === DOWNLOAD ===
#

kernel versatile-pb.dtb:
	$(Q)if [ -d qemu-rpi-kernel ] ; then \
		echo "UP qemu-rpi-kernel" ;\
		cd qemu-rpi-kernel ;\
		git pull ;\
		cd - ;\
	else \
		echo "DL qemu-rpi-kernel" ;\
		git clone --depth=1 --progress git@github.com:dhruvvyas90/qemu-rpi-kernel.git ;\
	fi
	$(Q)echo "CP $@"
	$(Q)cp qemu-rpi-kernel/kernel-qemu-*-buster kernel
	$(Q)cp qemu-rpi-kernel/versatile-pb.dtb versatile-pb.dtb

rasbian.img: | qemu
	$(Q)echo "DL $%.zip"
	$(Q)curl --progress-bar -L https://downloads.raspberrypi.org/raspbian_latest --output rasbian.zip
	$(Q)echo "CP $@"
	$(Q)unzip -qq -u rasbian.zip
	$(Q)qemu-img convert -p -f raw -O qcow2 *-raspbian-*.img $@
	$(Q)qemu-img resize $@ $(IMG_SIZE)

.PHONY: qemu
qemu:
	$(Q)echo "DL qemu"
	$(Q)sudo apt-get -qq install qemu-system-arm


#
## === START/STOP ===
#

mkfile_path := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
$(SCRIPTS):
	$(Q)echo "CP $@"
	$(Q)ln -s $(mkfile_path)/$@ .


#
## === CLEAN ===
#

.PHONY: clean
clean:
	$(Q)rm -f  -- rasbian.zip
	$(Q)rm -f  -- *-*.img
	$(Q)rm -rf -- qemu-rpi-kernel

.PHONY: distclean
distclean: clean
	$(Q)rm -f -- $(ALL)
