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

# Use this makefile as root

.PHONY: bootstrap system modules iso

SRC=$(shell pwd)

help:
	@echo "✨ Welcome to the Dyne:IV SDK by Dyne.org!"
	@awk 'BEGIN {FS = ":.*##"; printf "🛟 Usage: make \033[36m<target>\033[0m\n👇🏽 List of targets:\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf " \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5)} ' Makefile


include config.mk

----: ## __ Quick test on emulator:

sync-root: SDK := dyneIV-sdk-${ARCH}.tar.xz
sync-root: ISO ?= dynebolic.iso
sync-root: ## 📥 Download the latest SDK build ROOT
	$(if $(wildcard ${ROOT}),$(error Existing SDK detected, first make clean))
	$(info Downloading and restoring the latest SDK environment)
	rsync -PL files.dyne.org::dynebolic/sdk/${SDK} ${SDK}
	mkdir -p ${ROOT}
	tar -C ${ROOT} -xf ${SDK}

snap-test: need-suid ## 🧨 Test a squashed snapshot FILE=path
	$(if $(wildcard ${FILE}),,$(error FILE env var not found: ${FILE}))
	make -C iso iso-snapshot FILE=${FILE}

qemu-grub: ISO ?= dynebolic.iso
qemu-grub: persist := $(if $(wildcard persistence.qcow2),-hda persistence.qcow2)
qemu-grub: test-hdd := $(if $(wildcard hdd.qcow2),-hdb hdd.qcow2)
qemu-grub: ## 🖥️ Emulate UEFI USB boot using qemu
	$(info Launch QEMU emulator on ISO using UEFI BIOS)
	qemu-system-x86_64 -enable-kvm -bios /usr/share/ovmf/OVMF.fd	\
	-cdrom ${ISO} ${persist} ${test-hdd} --boot once=d -m 2048 -smp 4	\
	${QEMU_CONF}

_: ##
-----: ## __ More emulator functions:

qemu-isolinux: ISO ?= dynebolic.iso
qemu-isolinux: persist := $(if $(wildcard persistence.qcow2),-hda persistence.qcow2)
qemu-isolinux: ## 📀 Emulate DVD boot using qemu
	$(info Launch QEMU emulator on ISO)
	qemu-system-x86_64 -enable-kvm -cdrom ${ISO} ${persist}	\
	--boot once=d -m 2048 -smp 4 ${QEMU_CONF}

qemu-spice: ISO ?= dynebolic.iso
qemu-spice: persist := $(if $(wildcard persistence.qcow2),-hda persistence.qcow2)
qemu-spice: ## 🖥️ Emulate via SPICE (requires LAN client)
	$(info Launch SPICE server on LAN port 5900)
	QEMU_AUDIO_DRV=spice qemu-system-x86_64 -enable-kvm -bios		\
	/usr/share/ovmf/OVMF.fd -cdrom ${ISO} ${persist} --boot	\
	once=d -m 2048 -smp 4 ${QEMU_CONF} -machine vmport=off -vga qxl	\
	-spice port=5900,addr=0.0.0.0,disable-ticketing=on -device	\
	virtio-serial-pci -device virtio-serial -chardev				\
	spicevmc,id=vdagent,debug=0,name=vdagent -device				\
	virtserialport,chardev=vdagent,name=com.redhat.spice.0

persist-create: NBD ?= 14
persist-create: need-suid ## 💾 Create persistance storage for qemu
	$(if $(wildcard persistence.qcow2),$(error Cannot overwrite persistence.qcow2))
	$(info Creating persistence qcow2 file for Qemu)
	modprobe nbd
	qemu-img create -f qcow2 persistence.qcow2 10G
	qemu-nbd -c /dev/nbd${NBD} persistence.qcow2
	parted -s /dev/nbd${NBD} -- mklabel msdos mkpart primary ext4 1 -1 set 1 boot off
	mkfs.ext4 -L dyne.nst /dev/nbd${NBD}p1
	mkdir -p mnt && mount /dev/nbd${NBD}p1 mnt \
	&& echo "/home union"  > mnt/persistence.conf \
	&& echo "/root union" >> mnt/persistence.conf \
	&& echo "/etc union" >> mnt/persistence.conf \
	&& echo "/var union" >> mnt/persistence.conf \
	&& echo "/usr union" >> mnt/persistence.conf \
	  && umount mnt
	qemu-nbd -d /dev/nbd${NBD}
	chmod a+rw persistence.qcow2

persist-mount: FILE ?= persistence.qcow2
persist-mount: MNT ?= mnt
persist-mount: need-suid ## 🔍 Mount persistance contents in qcow2
	$(if $(wildcard ${FILE}),,$(error Cannot find qcow2: ${FILE}))
	mkdir -p ${MNT}
	$(call mount-qcow2,${FILE},${MNT})

persist-umount: MNT ?= mnt
persist-umount: need-suid ## ⏏️ Unmount persistance contents
	$(call umount-qcow2,${MNT})

persist-sync: FILE ?= persistence.qcow2
persist-sync: MNT ?= mnt
persist-sync: need-suid
	$(if $(wildcard ${FILE}),,$(error Cannot find qcow2: ${FILE}))
	mkdir -p ${MNT}
	$(call mount-qcow2,${FILE},${MNT})
	rsync -raX ${MNT}/rw/home/dyne/.config/* ${SRC}/static/home/dyne/.config/ \
		--exclude libaccounts-glib --exclude kdeconnect
	rsync -raX ${MNT}/rw/usr/share/wallpapers/dyne ${SRC}/static/usr/share/wallpapers/
	$(call umount-qcow2,${MNT})

_: ##
-----: ## __ Build from sources:

# local system dependencies needed to build a live system
deps: need-suid ## 🛠️ Install development dependencies
	$(info Install all development dependencies)
	apt-get install mmdebstrap squashfs-tools xorriso isolinux syslinux \
    syslinux-efi syslinux-common syslinux-utils grub-pc-bin           \
    grub-efi-amd64-bin grub-efi-ia32-bin mtools dosfstools            \
    squashfs-tools-ng pv schroot uidmap qemu-utils ovmf rsync wget    \
    xz-utils

bootstrap: ## 🚀 Install the base system: dyneIV-bootstrap
	@make -C bootstrap

system: ## 🗿 Install the full system: dyneIV-system
	@make -C system all

upgrade: ## 🔝 Update all system packages
	$(call upgrade-packages)
	@make -C system all

chroot: SCONF := /etc/schroot/chroot.d/dynebolic.conf
chroot: ## 🚪 Enter the current build ROOT via CLI
	@-[ -r /etc/schroot/dyne ] || sh schroot-setup.sh
	@-if ! [ -r ${SCONF} ]; then \
		cp schroot.conf ${SCONF} && echo "directory=${ROOT}" >> ${SCONF}; fi
	$(info Enter ROOT)
	@schroot -c dyne -u root -d /root

desktop: need-suid
	$(info Launch the Desktop)
	xhost + local:
	cp desktop.sh ${ROOT}/
	chroot ${ROOT} sh desktop.sh
	rm -f ${ROOT}/desktop.sh

# experimental
# xhost + local:
bwrap:
	@command -v bwrap || exit 1
	bwrap --bind ${ROOT} / --proc /proc --dev /dev --unshare-user --share-net \
		--uid 0 --gid 0 bash

_: ##
-----: ## __ Module development:  (PATH=modname)
modules: ## 🧩 Build all default modules
	-make -C modules kde
	-make -C modules multimedia
	-make -C modules games

_: ##
-----: ## __ Release the live bootable system


squash: ## 🗜️ Compress the filesystem for release
	make -C iso squash
	make -C modules modsquash

squash-dev: ## 🦺 Compress the filesystem for developers
	make -C iso squash-devel
	make -C modules modsquash

buildroot: ## 🏗️ Package the build ROOT  for developers
	make -C iso buildroot

iso: ## 🏁 Toast the current ISO image
	make -C iso iso

burn: ISO ?= dynebolic.iso
burn: ## 🔥 Write the ISO to a removable USB=/dev/sd?
	$(if $(wildcard ${ISO}),,$(error ${ISO} not found.))
	$(if $(wildcard ${USB}),,$(error USB device not found: ${USB}))
	$(info This will delete all contents of device: ${USB})
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	dd if=${ISO} of=${USB} bs=1M oflag=direct status=progress

_: ##
-----: ## __ Undo and restart from scratch

reset: need-suid ## ♻️  Reset current ROOT to the latest downloaded
	$(if $(wildcard ${STAGE3}),,$(error System squash not found: ${STAGE3}))
	$(if $(wildcard ${STAGE3DEV}),,$(error Development archive not found: ${STAGE3DEV}))
	$(info Restore ROOT from ${STAGE3} and ${STAGE3DEV})
	@rm -rf ${ROOT}
	@mkdir -p ${ROOT} && cd ${ROOT} && \
		unsquashfs -d . ${SRC}/${STAGE3}

restrap: need-suid ## ♻️  Reset current ROOT to base bootstrap stage
	$(info Restore ROOT from ${STAGE2})
	@$(if $(wildcard ${ROOT}/proc/meminfo),umount ${ROOT}/proc)
	@rm -rf ${ROOT}
	@mkdir -p ${ROOT} && cd ${ROOT} && tar -xf ${SRC}/${STAGE2}

# @if [ -r ${SRC}/${STAGE3DEV} ]; then \
# 	tar -xf ${SRC}/${STAGE3DEV}	var/cache/apt/archives; fi

clean: need-suid ## 🧹  Delete ROOT
	@$(if $(wildcard ${ROOT}/proc/meminfo),umount ${ROOT}/proc)
	@$(if $(wildcard ${ROOT}/dev/mem),umount ${ROOT}/dev)
	@rm -rf ${ROOT}
	@rm -rf modules/*-mnt
	@rm -rf build

######
## Publishing operations (ssh key restricted)

publish: ISO ?= dynebolic.iso
publish: rcd := /srv/ftp/dynebolic/development
publish: date := $(shell date +%Y%m%d)
publish:
	ssh dyne.files 'cd ${rcd} && cp -L dyneIV-latest.iso dyneIV-${date}.iso'
	rsync -P ${ISO} dyne.files:${rcd}/dyneIV-${date}.iso
	ssh dyne.files 'cd ${rcd} && ln -sf dyneIV-${date}.iso dyneIV-latest.iso && sha512sum *iso *tar* | grep -v latest | tee SHA512SUMS.txt'

# 	ssh dyne.files 'cd ${rcd} && cp -L dyneIV-latest-dev.tar.xz dyneIV-${date}-dev.tar.xz'
# 	rsync -P dyneIV-system-${ARCH}-dev.tar.xz dyne.files:/srv/ftp/dynebolic/development/dyneIV-${date}-dev.tar.xz
#  && ln -sf dyneIV-${date}-dev.tar.xz dyneIV-latest-dev.tar.xz

rsync-server: tmp := $(shell mktemp)
rsync-server: here := $(shell pwd)
rsync-server:
	cp rsync.conf ${tmp}
	echo "  path = ${here}" >> ${tmp}
	rsync --daemon --verbose --no-detach --config ${tmp}

source-packages:
	$(call chroot-script,source-packages.sh)
	@mv ROOT/usr/src/source-packages .

######
## Development operations
test-hdd-create: FILE ?= hdd.qcow2
test-hdd-create: NBD ?= 14
test-hdd-create: need-suid
	$(if $(wildcard ${FILE}),$(error Cannot overwrite ${FILE}))
	$(info Creating ${FILE} file for Qemu)
	modprobe nbd
	qemu-img create -f qcow2 ${FILE} 10G
	qemu-nbd -c /dev/nbd${NBD} ${FILE}
	parted -s /dev/nbd${NBD} -- mklabel msdos mkpart primary ext4 1 -1 set 1 boot off
	mkfs.ext4 -L hdd /dev/nbd${NBD}p1
	qemu-nbd -d /dev/nbd${NBD}
	chmod a+rw ${FILE}

test-hdd-mount: FILE ?= hdd.qcow2
test-hdd-mount: MNT ?= mnt
test-hdd-mount: need-suid
	$(if $(wildcard ${FILE}),,$(error Cannot find qcow2: ${FILE}))
	mkdir -p ${MNT}
	$(call mount-qcow2,${FILE},${MNT})

test-hdd-umount: MNT ?= mnt
test-hdd-umount: need-suid
	$(call umount-qcow2,${MNT})

