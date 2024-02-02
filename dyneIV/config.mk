FILEPFX ?= dyneIV
ARCH ?= amd64
# temporary rootfs in RAM to speed up and avoid ssd usage
# ROOT ?= /dev/shm/dynebolic-rootfs
ROOT ?= $(shell git rev-parse --show-toplevel)/dyneIV/ROOT

STAGE1 := ${FILEPFX}-stage1-${ARCH}.tar
STAGE2 := ${FILEPFX}-stage2-${ARCH}.tar.gz
STAGE3 := ${FILEPFX}-stage3-${ARCH}.tar.xz

.PHONY: check-root chroot-script need-suid static-overlay chroot desktop bwrap

UID := $(shell id -u)
PWD := $(shell pwd)

QEMU_CONF ?= -device intel-hda -device hda-duplex -device nec-usb-xhci,id=usb -chardev spicevmc,name=usbredir,id=usbredirchardev1 -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 -chardev spicevmc,name=usbredir,id=usbredirchardev2 -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 -chardev spicevmc,name=usbredir,id=usbredirchardev3 -device	usb-redir,chardev=usbredirchardev3,id=usbredirdev3

need-suid:
ifneq (${UID}, 0)
	@echo "Run as root." && exit 1
endif

define check-root
	$(if $(wildcard ${ROOT}),,$(error "ROOT not found."))
endef

define chroot-script
	$(if $(wildcard ${1}),,$(error Script not found: ${1}))
	@echo "--\n-- Execute: ${1}"
	@cp    "${1}" ${ROOT}/script.sh
	@chroot ${ROOT} bash /script.sh
	@rm -f ${ROOT}/script.sh
	@echo "-- Done ${1}\n--"
endef

define install-packages
	$(if $(wildcard ${1}),,$(error Package file not found: ${1}))
	$(if $(wildcard ${ROOT}),,$(error ${ROOT} not found))
	@echo "-- Install ${1}\n--"
	@echo "DEBIAN_FRONTEND=noninteractive apt-get install -q -y $(shell awk '/^$$/{next} !/^#/{printf("%s ",$$1)}' ${1})" > ${ROOT}/install.sh
	chroot ${ROOT} sh /install.sh
	rm -f ${ROOT}/install.sh
	@echo "-- Done ${1}\n--"
endef

define remove-paths
	$(if $(wildcard ${1}),,$(error Path file not found: ${1}))
	$(if $(wildcard ${ROOT}),,$(error ${ROOT} not found))
	@echo "-- Remove ${1}\n--"
	@echo "rm -rf $(shell awk '/^$$/{next} !/^#/{printf("%s ",$$1)}' ${1})" > ${ROOT}/remove.sh
	chroot ${ROOT} sh /remove.sh
	rm -f ${ROOT}/remove.sh
	@echo "-- Done ${1}\n--"
endef

define upgrade-packages
	$(if $(wildcard ${ROOT}),,$(error ${ROOT} not found))
	@echo "-- Upgrade packages\n--"
	@echo "DEBIAN_FRONTEND=noninteractive apt-get update -q -y" > ${ROOT}/upgrade.sh
	@echo "DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y" > ${ROOT}/upgrade.sh
	chroot ${ROOT} sh /upgrade.sh
	rm -f ${ROOT}/upgrade.sh
	@echo "-- Done\n--"
endef

define apply-patch
	$(if $(wildcard ${ROOT}/${1}),,$(error Patch target file not found: ${1}))
	$(if $(wildcard ${2}),,$(error Patch file not found: ${2}))
	@echo "-- Patch ${1}\n--"
	cp ${2} ${ROOT}/apply.patch
	chroot ${ROOT} 'patch -p1 ${1} < /apply.patch'
	rm -f ${ROOT}/apply.patch
endef

define mount-qcow2
	$(if $(wildcard ${1}),,$(error QCOW2 file not found: ${1}))
	$(if $(wildcard ${2}),,$(error Mountpoint not found: ${2}))
	@echo "-- Mount ${1} on ${2}\n--"
	modprobe nbd
	qemu-nbd --connect=/dev/nbd0 "${1}"
	mount /dev/nbd0p1 "${2}"
endef

define umount-qcow2
	$(if $(wildcard ${1}),,$(error Mountpoint not found: ${1}))
	@echo "-- Unmount ${1} (QCOW2)\n--"
	umount "${1}"
	qemu-nbd --disconnect /dev/nbd0
endef


shrink: need-suid
	$(if $(wildcard ${ROOT}),,$(error ROOT not found))
	$(info Shrink the system)
	@-find ${ROOT}/ -type d -name '__pycache__' -exec rm -rvf {} \;
	@-find ${ROOT}/var/log/ -type f -name '*.log' -exec rm -rvf {} \;
	@rm -rvf ${ROOT}/tmp/* ${ROOT}/var/tmp/*
	@chroot ${ROOT} apt-get autoremove
	@chroot ${ROOT} apt-get clean

# rm -rvf ${ROOT}/usr/share/gtk-doc/*
# rm -rvf ${ROOT}/usr/share/man/*
# rm -rvf ${ROOT}/usr/share/help/*
# rm -rvf ${ROOT}/usr/share/info/*
# rm -rvf ${ROOT}/usr/share/doc/*
