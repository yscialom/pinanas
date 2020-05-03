IMG_SIZE=32G
Q=@
SCRIPTS=start
ALL=kernel versatile-pb.dtb raspbian.img $(SCRIPTS)

mkfile_path := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

all: $(ALL)
	$(Q)./start

kernel versatile-pb.dtb:
	$(Q)if [ -d qemu-rpi-kernel ] ; then \
		echo "UPD qemu-rpi-kernel" ;\
		cd qemu-rpi-kernel ;\
		git pull ;\
		cd - ;\
	else \
		echo "GET qemu-rpi-kernel" ;\
		git clone --depth=1 --progress git@github.com:dhruvvyas90/qemu-rpi-kernel.git ;\
	fi
	$(Q)echo "GET $@"
	$(Q)cp qemu-rpi-kernel/kernel-qemu-*-buster kernel
	$(Q)cp qemu-rpi-kernel/versatile-pb.dtb versatile-pb.dtb

raspbian.img: | qemu
	$(Q)echo "GET raspbian.zip"
	$(Q)test -f raspbian.zip || curl --progress-bar -L https://downloads.raspberrypi.org/raspbian_latest --output raspbian.zip
	$(Q)echo "GET $@"
	$(Q)unzip -qq -u raspbian.zip
	$(Q)sudo $(mkfile_path)/installfirststart.sh *-raspbian-*.img $(mkfile_path)/../guest
	$(Q)qemu-img convert -p -f raw -O qcow2 *-raspbian-*.img $@
	$(Q)qemu-img resize $@ $(IMG_SIZE)

.PHONY: qemu
qemu:
	$(Q)echo "GET qemu"
	$(Q)sudo apt-get -qq install qemu-system-arm


$(SCRIPTS):
	$(Q)echo "GET $@"
	$(Q)ln -s $(mkfile_path)/$@ .


#
## === CLEAN ===
#

.PHONY: clean
clean:
	$(Q)rm -f  -- raspbian.zip
	$(Q)rm -f  -- *-*.img
	$(Q)rm -rf -- qemu-rpi-kernel

.PHONY: distclean
distclean: clean
	$(Q)rm -f -- $(ALL)
