# Copyright (C) 2023-2024 Dyne.org Foundation
#
# Designed, written and maintained by Denis Roio <jaromil@dyne.org>
#
# This source code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This source code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	Please refer
# to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, , see <https://www.gnu.org/licenses/>.

FILEPFX ?= dyneIV
ARCH ?= amd64

# TODO: live-boot supports only .squashfs extension
# MODEXT ?= dyne

# ISO components in mount order
COMPONENTS ?= root home mod-kde mod-multimedia mod-games static

# temporary rootfs in RAM to speed up and avoid ssd usage
# ROOT ?= /dev/shm/dynebolic-rootfs
ROOT ?= $(shell git rev-parse --show-toplevel)/dyneIV/ROOT

# Configure custom proxy apt cache
#APT_PROXY_OVERRIDE := "192.168.122.168:3142"
#APT_PROXY_OVERRIDE := "127.0.0.2:3142"
APT_PROXY_OVERRIDE := ""

# Bootstrap stages filenames
STAGE0 := ${FILEPFX}-stage0-${ARCH}.tar
STAGE1 := ${FILEPFX}-stage1-${ARCH}.tar.xz
STAGE2 := ${FILEPFX}-stage2-${ARCH}.tar.xz

SQFSCONF ?= -c xz -j 6

# check also exclude-from-iso.txt to avoid excludes
# DEV_PATHS := var/lib/apt var/lib/dpkg var/cache/apt var/cache/debconf /usr/src

.PHONY: check-root chroot-script need-suid static-overlay chroot desktop bwrap prepare-excludes

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
	@rm -f ${ROOT}/fail
	@cp    "${1}" ${ROOT}/script.sh
	@mount -o bind /proc ${ROOT}/proc
	@mount -o bind /dev ${ROOT}/dev
	chroot ${ROOT} bash -e /script.sh || touch ${ROOT}/fail
	@umount ${ROOT}/dev
	@umount ${ROOT}/proc
	@test ! -r ${ROOT}/fail || echo "-- Fail: ${1}\n--"
	@echo "-- Done ${1}\n--"
endef

define chroot-script-into
	$(if $(wildcard ${1}),,$(error Script not found: ${1}))
	$(if $(wildcard ${2}),,$(error Folder not found: ${2}))
	@echo "--\n-- Execute: ${1} into ${2}"
	@rm -f ${2}/fail
	@cp    "${1}" ${2}/script.sh
	@mkdir ${2}/proc ${2}/dev
	@mount -o bind /proc ${2}/proc
	@mount -o bind /dev ${2}/dev
	chroot ${2} bash -e /script.sh || touch ${2}/fail
	@umount ${2}/dev
	@umount ${2}/proc
	@rmdir ${2}/proc ${2}/dev
	@test ! -r ${2}/fail || echo "-- Fail: ${1} into ${2}\n--"
	@echo "--\n-- Done ${1} into ${2}\n--"
endef

define upgrade-packages
	@echo "--\n-- Apt Get Update & Upgrade"
	@echo "DEBIAN_FRONTEND=noninteractive apt-get -q -y update" >> ${ROOT}/upgrade.sh
	@echo "DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade" >> ${ROOT}/upgrade.sh
	mount -o bind /proc ${ROOT}/proc
	mount -o bind /dev/pts ${ROOT}/dev/pts
	mount -o bind /dev/null ${ROOT}/dev/null
	-chroot ${ROOT} bash -e /upgrade.sh
	-umount ${ROOT}/proc
	-umount ${ROOT}/dev/pts
	-umount ${ROOT}/dev/null
	@echo "-- Done Apt Get Upgrade\n--"
endef

define install-packages
	$(if $(wildcard ${1}),,$(error Package file not found: ${1}))
	$(if $(wildcard ${ROOT}),,$(error ${ROOT} not found))
	@echo "-- Install ${1}\n--"
	@echo "DEBIAN_FRONTEND=noninteractive apt-get install -q -y $(shell awk '/^$$/{next} !/^#/{printf("%s ",$$1)}' ${1})" > ${ROOT}/install.sh
	mount -o bind /proc ${ROOT}/proc
	mount -o bind /dev/pts ${ROOT}/dev/pts
	-chroot ${ROOT} bash -e /install.sh
	-umount ${ROOT}/proc
	-umount ${ROOT}/dev/pts
	@echo "-- Done ${1}\n--"
endef

define remove-paths
	$(if $(wildcard ${1}),,$(error Path file not found: ${1}))
	$(if $(wildcard ${ROOT}),,$(error ${ROOT} not found))
	@echo "-- Remove ${1}\n--"
	@echo "rm -rf $(shell awk '/^$$/{next} !/^#/{printf("%s ",$$1)}' ${1})" > ${ROOT}/remove.sh
	chroot ${ROOT} bash -e /remove.sh
	@echo "-- Done ${1}\n--"
endef

define apply-patch
	$(if $(wildcard ${ROOT}/${1}),,$(error Patch target file not found: ${1}))
	$(if $(wildcard ${2}),,$(error Patch file not found: ${2}))
	@echo "-- Patch ${1}\n--"
	cp ${2} ${ROOT}/apply.patch
	chroot ${ROOT} 'patch -p1 ${1} < /apply.patch'
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


# shrink: need-suid
# 	$(if $(wildcard ${ROOT}),,$(error ROOT not found))
# 	$(info Shrink the system)
# 	@-find ${ROOT}/ -type d -name '__pycache__' -exec rm -rvf {} \;
# 	@-find ${ROOT}/var/log/ -type f -name '*.log' -exec rm -rvf {} \;
# 	@rm -rvf ${ROOT}/tmp/* ${ROOT}/var/tmp/*
# 	@chroot ${ROOT} apt-get autoremove
# 	@chroot ${ROOT} apt-get clean

# rm -rvf ${ROOT}/usr/share/gtk-doc/*
# rm -rvf ${ROOT}/usr/share/man/*
# rm -rvf ${ROOT}/usr/share/help/*
# rm -rvf ${ROOT}/usr/share/info/*
# rm -rvf ${ROOT}/usr/share/doc/*
