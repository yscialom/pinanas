#
## === USAGE ===
#
# Preferably out-of-source (in an empty directory), invoke this makefile with
#     make -f /path/to/this/file $target
# with $target being:
#   - build: to build the raw image (see configuration section bellow for the image name and size);
#   - qemulation: to download and setup files needed to run the OS with qemu; generates a start script that can be called without argument;
#   - release: to package a release (see configuration section bellow for the release name);
#   - clean: to remove temporary build files;
#   - mostlyclean: to remove all generated files but the packaged release;
#   - distclean: to remove all generated files (temporary and built).
#
# Example workflow:
#     mkdir build && cd build
#     alias make='make -f ../os/linux-host/Makefile'
#     make build       # builds raspbian.img
#     make qemulaion   # prepare everything to emulate the OS
#     ./start          # emulate the OS fir its first start; this can take dozen minutes to hours
#     make release     # package somename-os-$version.gz
#     make mostlyclean # removes work files
#

#
## === CONFIGURATION ===
#

# Virtual size of the generated image
IMAGE_SIZE=32G

# SomeName OS version
SNOS_VERSION=$(shell git describe --tags 2>/dev/null || echo "0.0.1")

# Image name
IMAGE_NAME=somename-os-$(SNOS_VERSION).img

# Release name (extension is used by tar -a to infer compression to use)
RELEASE_NAME=somename-os-$(SNOS_VERSION).gz

# Quiet make? @: silent, empty: verbose
Q=@


#
## === WORK VARIABLES ===
#
LINUX_SCRIPTS_DIR=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

.PHONE: debug
debug:
	@echo "LINUX_SCRIPTS_DIR: $(LINUX_SCRIPTS_DIR)"
	@echo "RELEASE_NAME     : $(RELEASE_NAME)"
	@exit 0

#
## === BUILD ===
#

.PHONY: build
build: $(IMAGE_NAME)

$(IMAGE_NAME):
	$(Q)echo "GET $@.zip"
	$(Q)test -f $@.zip || curl --progress-bar -L "https://downloads.raspberrypi.org/raspbian_latest" --output $@.zip
	$(Q)echo "GET $@"
	$(Q)unzip -qq -u $@.zip
	$(Q)echo "root permission needed to mount image in order to alter it"
	$(Q)sudo $(LINUX_SCRIPTS_DIR)/installfirststart.sh *-raspbian-*.img $(LINUX_SCRIPTS_DIR)/../guest
	$(Q)mv *-raspbian-*.img $@
	$(Q)command -v qemu-img || (echo "error: qemu-img required; command not found.">&2 ; exit 1)
	$(Q)qemu-img resize -f raw $@ $(IMAGE_SIZE)


#
## === QEMULATION ===
#

.PHONY: qemulation
qemulation: kernel versatile-pb.dtb start

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

start:
	$(Q)command -v qemu-system-arm >/dev/null || (echo "error: qemu-system-arm required; command not found">&2 ; exit 1)
	$(Q)ln -s $(LINUX_SCRIPTS_DIR)/start .


#
## === RELEASE ===
#

.PHONY: release
release: $(RELEASE_NAME)

$(RELEASE_NAME): $(IMAGE_NAME)
	$(Q)echo "ARZ  $(RELEASE_NAME)"
	$(Q)GZIP=-9 tar -caf $(RELEASE_NAME) $(IMAGE_NAME)


#
## === CLEAN ===
#

.PHONY: clean distclean
clean:
	$(Q)rm -f  -- $(IMAGE_NAME).zip
	$(Q)rm -f  -- *-*.img
	$(Q)rm -rf -- qemu-rpi-kernel

mostlyclean:clean
	$(Q)rm -f -- kernel versatile-pb.dtb start $(IMAGE_NAME)

distclean: mostlyclean
	$(Q)rm -f -- $(RELEASE_NAME)
