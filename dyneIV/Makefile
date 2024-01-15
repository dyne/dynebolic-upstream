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

.PHONY: bootstrap packages iso

SRC=$(shell pwd)

help:
	@awk 'BEGIN {FS = ":.*##"; printf "🛟 Usage:\n   make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5)} ' Makefile


include config.mk

----: ## Quick test on emulator:

sync-iso: ## 📥 Sync latest online development ISO
	rsync -PL files.dyne.org::dynebolic/dyneIV-latest.iso dynebolic.iso

sync-stage3: ## 📥 Sync latest online stage3 tarball
	rsync -PL files.dyne.org::dynebolic/dyneIV-stage3-amd64.tar.gz dyneIV-stage3-amd64.tar.gz

qemu-dvd: persist := $(if $(wildcard persistence.qcow2),-hda persistence.qcow2)
qemu-dvd: ## 📀 Emulate DVD boot using qemu
	$(info Launch QEMU emulator on ISO)
	qemu-system-x86_64 -enable-kvm -cdrom dynebolic.iso ${persist}	\
	--boot once=d -m 2048 -smp 4 ${QEMU_CONF}

qemu-usb: persist := $(if $(wildcard persistence.qcow2),-hda persistence.qcow2)
qemu-usb: ## 🖥️ Emulate USB boot using qemu
	$(info Launch QEMU emulator on ISO using UEFI BIOS)
	qemu-system-x86_64 -enable-kvm -bios /usr/share/ovmf/OVMF.fd	\
	-cdrom dynebolic.iso ${persist} --boot once=d -m 2048 -smp 4	\
	${QEMU_CONF}

persist-create: NBD ?= 14
persist-create: need-suid ## 💾 Create persistance storage for qemu
	$(if $(wildcard persistence.qcow2),$(error Cannot overwrite persistence.qcow2))
	$(info Creating persistence qcow2 file for Qemu)
	modprobe nbd
	qemu-img create -f qcow2 persistence.qcow2 10G
	qemu-nbd -c /dev/nbd${NBD} persistence.qcow2
	parted -s /dev/nbd${NBD} -- mklabel msdos mkpart primary ext4 1 -1 set 1 boot off
	mkfs.ext4 -L persistence /dev/nbd${NBD}p1
	mkdir -p mnt && mount /dev/nbd${NBD}p1 mnt \
	  && echo "/ union" > mnt/persistence.conf \
	  && umount mnt
	qemu-nbd -d /dev/nbd${NBD}
	chmod a+rw persistence.qcow2

persist-mount: FILE ?= persistence.qcow2
persist-mount: MNT ?= mnt
persist-mount: need-suid ## 💾 Mount persistance contents in qcow2
	$(if $(wildcard ${FILE}),,$(error Cannot find qcow2: ${FILE}))
	mkdir -p ${MNT}
	$(call mount-qcow2,${FILE},${MNT})

persist-umount: MNT ?= mnt
persist-umount: need-suid ## 💾 Unmount persistance contents
	$(call umount-qcow2,${MNT})

persist-mount: FILE ?= persistence.qcow2
persist-mount: MNT ?= mnt
persist-sync: need-suid
	$(if $(wildcard ${FILE}),,$(error Cannot find qcow2: ${FILE}))
	mkdir -p ${MNT}
	$(call mount-qcow2,${FILE},${MNT})
	rsync -raX ${MNT}/home/dyne/.config usr-config
	rsync -raX ${MNT}/usr/share/dynebolic usr-share
	$(call umount-qcow2,${MNT})

_: ##
-----: ## Build from source:

# local system dependencies needed to build a live system
development: need-suid ## 🛠️ Install development dependencies
	$(info Install all development dependencies)
	apt-get install mmdebstrap squashfs-tools xorriso isolinux			\
    syslinux syslinux-efi syslinux-common syslinux-utils grub-pc-bin	\
    grub-efi-amd64-bin grub-efi-ia32-bin mtools dosfstools				\
    squashfs-tools-ng pv schroot uidmap qemu-utils ovmf

bootstrap: ## 🚀 Bootstrap the base system: stage1, stage2
	@make -C bootstrap

packages: ## 🗿 Install packages: create stage3
	@make -C packages

upgrade: ## Update packages: install up to latest packages
	$(call upgrade-packages)
	@make -C packages install-all-packages

chroot: SCONF := /etc/schroot/chroot.d/dynebolic.conf
chroot:
	@-[ -r /etc/schroot/dyne ] || sh schroot-setup.sh
	@-if ! [ -r ${SCONF} ]; then \
		cp schroot.conf ${SCONF} && echo "directory=${ROOT}" >> ${SCONF}; fi
	$(info Enter ROOT)
	@schroot -c dyne -u root -d /root

desktop:
	$(info Launch the Desktop)
	xhost + local:
	sudo cp desktop.sh ${ROOT}/
	sudo chroot ${ROOT} sh desktop.sh
	sudo rm -f ${ROOT}/desktop.sh

# experimental
bwrap:
	@command -v bwrap || exit 1
	xhost + local:
	bwrap --bind ${ROOT} / --proc /proc --dev /dev --unshare-user --share-net \
		--uid 0 --gid 0 bash


iso: ## 🏁 Toast the final ISO image for release
	make -C iso

clean: need-suid ## 🧹 Cleanup current ROOT
	@rm -rf ${ROOT}

reset: need-suid ## 🧹 Reset current ROOT to stage3
	@rm -rf ${ROOT}
	@mkdir -p ROOT && cd ROOT && sudo tar xf ${SRC}/${STAGE3}


#	dpkg -i devuan-keyring_2023.05.28_all.deb
