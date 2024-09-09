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

----: ## __ Quick start:

# local system dependencies needed to build a live system
deps: need-suid ## 🛠️ Install development dependencies
	$(info Install all development dependencies)
	apt-get install mmdebstrap squashfs-tools xorriso isolinux syslinux \
    syslinux-efi syslinux-common syslinux-utils grub-pc-bin             \
    grub-efi-amd64-bin grub-efi-ia32-bin mtools dosfstools netcat-openbsd \
    squashfs-tools-ng pv uidmap qemu-utils ovmf rsync wget              \
    xz-utils fuse-overlayfs qemu-system-x86 qemu-system-gui squashfuse

setup: MODULES := root mod-kde static home
setup: ## 📥 Download the latest development ROOT modules
	$(if $(wildcard ${ROOT}),$(error Existing SDK detected, first make clean))
	$(info Downloading and restoring the latest SDK environment)
	mkdir -p ${SRC}/build
	for i in ${MODULES}; do \
		rsync -PL files.dyne.org::dynebolic/development/modules/dyneIV-$$i-${ARCH}.squashfs \
		${SRC}/build/; done
	make reset

system: ## 🗿 Build the root system: dyneIV-root
	@make -C system all

qemu: ISO ?= dynebolic.iso
qemu: persist := $(if $(wildcard persistence.qcow2),-hda persistence.qcow2)
qemu: test-hdd := $(if $(wildcard hdd.qcow2),-hdb hdd.qcow2)
qemu: ## 🖥️ Emulate UEFI USB boot using qemu
	$(info Launch QEMU emulator on ISO using UEFI BIOS)
	qemu-system-x86_64 -enable-kvm -bios /usr/share/ovmf/OVMF.fd	\
	-cdrom ${ISO} ${persist} ${test-hdd} --boot once=d -m 2048 -smp 4	\
	${QEMU_CONF}

burn: ISO ?= dynebolic.iso
burn: ## 🔥 Write the ISO to a removable USB=/dev/sd?
	$(if $(wildcard ${ISO}),,$(error ${ISO} not found.))
	$(if $(wildcard ${USB}),,$(error USB device not found: ${USB}))
	$(info This will delete all contents of device: ${USB})
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	dd if=${ISO} of=${USB} bs=1M oflag=direct status=progress

_: ##
-----: ## __ More emulator functions:

qemu-isolinux: ISO ?= dynebolic.iso
qemu-isolinux: persist := $(if $(wildcard persistence.qcow2),-hda persistence.qcow2)
qemu-isolinux: ## 📀 Emulate legacy boot (non-UEFI) using qemu
	$(info Launch QEMU emulator on ISO)
	qemu-system-x86_64 -enable-kvm -cdrom ${ISO} ${persist}	\
	--boot once=d -m 2048 -smp 4 ${QEMU_CONF}

qemu-spice: ISO ?= dynebolic.iso
qemu-spice: persist := $(if $(wildcard persistence.qcow2),-hda persistence.qcow2)
qemu-spice: ## 🖥️ E mulate via SPICE (requires LAN client)
	$(info Launch SPICE server on LAN port 5900)
	QEMU_AUDIO_DRV=spice qemu-system-x86_64 -enable-kvm -bios		\
	/usr/share/ovmf/OVMF.fd -cdrom ${ISO} ${persist} --boot	\
	once=d -m 2048 -smp 4 ${QEMU_CONF} -machine vmport=off -vga qxl	\
	-spice port=5900,addr=0.0.0.0,disable-ticketing=on -device	\
	virtio-serial-pci -device virtio-serial -chardev				\
	spicevmc,id=vdagent,debug=0,name=vdagent -device				\
	virtserialport,chardev=vdagent,name=com.redhat.spice.0

_: ##
-----: ## __ Snapshot testing functions:
snap-iso: QEMU ?= qemu
snap-iso: iso := $(realpath ${FILE})
snap-iso: need-suid ## 🧨 Test a squashed snapshot as ISO FILE=path
	$(if $(wildcard ${iso}),,$(error FILE env var not found: ${iso}))
	make -C iso iso-snapshot FILE=${iso}
	make ${QEMU} ISO=dynebolic-snapshot.iso

snap-mount: need-suid ## 👀 Explore the contents of a snapshot FILE=path
	$(if $(wildcard ${FILE}),,$(error FILE env var not found: ${FILE}))
	mkdir -p snap-mount
	squashfuse ${FILE} snap-mount

snap-umount: need-suid ## 🔌 Stop exploring and unplug the snapshot
	$(if $(wildcard snap-mount),,$(error snap-mount not found))
	fusermount -u snap-mount

test-changes: QEMU ?= qemu
test-changes: ISO ?= dynebolic-test.iso
test-changes: need-suid ## 🍳 Test current changes in home and static
	$(if $(wildcard ${ROOT}),,$(error ROOT not found: first make setup))
	make -C system home static
	make -C iso iso ISO=${ISO}
	make ${QEMU} ISO=${ISO}

persist-create: NBD ?= 14
persist-create: need-suid # 💾 Create persistance storage for qemu
	$(if $(wildcard persistence.qcow2),$(error Cannot overwrite persistence.qcow2))
	$(info Creating persistence qcow2 file for Qemu)
	modprobe nbd
	qemu-img create -f qcow2 persistence.qcow2 4G
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
persist-mount: need-suid # 🔍 Mount persistance contents in qcow2
	$(if $(wildcard ${FILE}),,$(error Cannot find qcow2: ${FILE}))
	mkdir -p ${MNT}
	$(call mount-qcow2,${FILE},${MNT})

persist-umount: MNT ?= mnt
persist-umount: need-suid # ⏏️ Unmount persistance contents
	$(call umount-qcow2,${MNT})

_: ##
-----: ## __ Build from scratch:

bootstrap: ## 🚀 Build the base system: dyneIV-bootstrap
	@make -C bootstrap

system: ## 🗿 Build the root system: dyneIV-root
	@make -C system root
	@make -C system home
	@make -C system static


modules: ## 🧩 Build all system modules (takes long...)
	make -C modules

upgrade: ## 🔝 Update root system packages
	$(call upgrade-packages)

iso: ## 🏁 Create the current ISO image
	make -C iso grub-check squash-static iso-staging grub-make iso-checksum iso \
		ISO=dynebolic.iso COMPONENTS="${COMPONENTS}"

_: #
-----: # __ Advanced development function

chroot: # 🚪 Enter the current build ROOT via CLI
	$(info Enter ROOT)
	@mount -o bind /proc ${ROOT}/proc
	@mount -o bind /dev ${ROOT}/dev
	@chroot ${ROOT} /bin/bash
	@umount ${ROOT}/dev
	@umount ${ROOT}/proc

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
-----: ## __ Undo and restart from scratch

reset: DEVROOT ?= ${SRC}/build/dyneIV-root-${ARCH}.squashfs
reset: need-suid ## ♻️  Reset current ROOT to the latest downloaded
	$(if $(wildcard ${DEVROOT}),,$(error Development ROOT not found: make setup))
	$(info Restore ROOT from ${DEVROOT})
	$(if $(wildcard ${ROOT}/proc/meminfo),umount ${ROOT}/proc)
	$(if $(wildcard ${ROOT}/dev/mem),umount ${ROOT}/dev)
	rm -rf ${ROOT}
	unsquashfs -d ${ROOT} ${DEVROOT}

restrap: need-suid ## ♻️  Reset current ROOT to base bootstrap stage
	$(info Restore ROOT from ${STAGE2})
	$(if $(wildcard ${STAGE2}),,$(error Bootstrap not found: make bootstrap))
	@$(if $(wildcard ${ROOT}/proc/meminfo),umount ${ROOT}/proc)
	@$(if $(wildcard ${ROOT}/dev/mem),umount ${ROOT}/dev)
	@rm -rf ${ROOT}
	@rm -rf modules/*-mnt modules/*-work modules/*-buildroot
	@mkdir -p ${ROOT} && cd ${ROOT} && tar -xf ${SRC}/${STAGE2}

# @if [ -r ${SRC}/${STAGE3DEV} ]; then \
# 	tar -xf ${SRC}/${STAGE3DEV}	var/cache/apt/archives; fi

clean: need-suid ## 🧹  Delete ROOT
	@rm -rf build/*

######
## Publishing operations (ssh key restricted)

publish: ISO ?= dynebolic.iso
publish: rcd := /srv/ftp/dynebolic/development
publish: date := $(shell date +%Y%m%d)
publish: MODULES := root mod-kde static home
publish:
	ssh dyne.files 'cd ${rcd} && cp -L dyneIV-latest.iso dyneIV-${date}.iso'
	rsync -P ${ISO} dyne.files:${rcd}/dyneIV-${date}.iso
	ssh dyne.files 'cd ${rcd} && ln -sf dyneIV-${date}.iso dyneIV-latest.iso && sha512sum *iso | grep -v latest | tee SHA512SUMS.txt'

# for i in ${MODULES}; do \
# 	rsync -P ${SRC}/build/dyneIV-$$i-${ARCH}.squashfs dyne.files:${rcd}/modules/; done

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

