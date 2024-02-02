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
	@echo "✨ Welcome to the Dyne:IV SDK by Dyne.org!"
	@awk 'BEGIN {FS = ":.*##"; printf "🛟 Usage: make \033[36m<target>\033[0m\n👇🏽 List of targets:\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf " \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5)} ' Makefile


include config.mk

----: ## __ Quick test on emulator:

sync-iso: ## 📥 Download latest development ISO
	rsync -PL files.dyne.org::dynebolic/dyneIV-latest.iso dynebolic.iso

qemu-usb: persist := $(if $(wildcard persistence.qcow2),-hda persistence.qcow2)
qemu-usb: ## 🖥️ Emulate USB boot using qemu
	$(info Launch QEMU emulator on ISO using UEFI BIOS)
	qemu-system-x86_64 -enable-kvm -bios /usr/share/ovmf/OVMF.fd	\
	-cdrom dynebolic.iso ${persist} --boot once=d -m 2048 -smp 4	\
	${QEMU_CONF}

_: ##
-----: ## __ More emulator functions:

sync-stage3: ## 📥 Download latest stage3 tarball (for reset)
	rsync -PL files.dyne.org::dynebolic/dyneIV-stage3-amd64.tar.gz dyneIV-stage3-amd64.tar.gz

qemu-dvd: persist := $(if $(wildcard persistence.qcow2),-hda persistence.qcow2)
qemu-dvd: ## 📀 Emulate DVD boot using qemu
	$(info Launch QEMU emulator on ISO)
	qemu-system-x86_64 -enable-kvm -cdrom dynebolic.iso ${persist}	\
	--boot once=d -m 2048 -smp 4 ${QEMU_CONF}

qemu-spice: persist := $(if $(wildcard persistence.qcow2),-hda persistence.qcow2)
qemu-spice: ## 🖥️ Emulate via SPICE  (requires network client)
	$(info Launch SPICE server on LAN port 5900)
	QEMU_AUDIO_DRV=spice qemu-system-x86_64 -enable-kvm -bios		\
	/usr/share/ovmf/OVMF.fd -cdrom dynebolic.iso ${persist} --boot	\
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
	apt-get install mmdebstrap squashfs-tools xorriso isolinux			\
    syslinux syslinux-efi syslinux-common syslinux-utils grub-pc-bin	\
    grub-efi-amd64-bin grub-efi-ia32-bin mtools dosfstools				\
    squashfs-tools-ng pv schroot uidmap qemu-utils ovmf rsync wget

stage2: ## 🚀 Build the base system: stage1, stage2
	@make -C bootstrap

stage3: ## 🗿 Build the desktop: create stage3
	@make -C packages

upgrade: ## 🔝 Update all packages in stage3
	$(call upgrade-packages)
	@make -C packages install-all-packages

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
bwrap:
	@command -v bwrap || exit 1
	xhost + local:
	bwrap --bind ${ROOT} / --proc /proc --dev /dev --unshare-user --share-net \
		--uid 0 --gid 0 bash

iso: ## 🏁 Toast the final ISO image for release
	make -C iso


_: ##
-----: ## __ Undo and restart from scratch

reset: need-suid ## ♻️ Reset current ROOT to stage3
	$(info Restore ROOT from ${STAGE3})
	@rm -rf ${ROOT}
	@mkdir -p ${ROOT} && cd ${ROOT} && tar xf ${SRC}/${STAGE3}

reset-stage2: need-suid ## ♻️ Reset current ROOT to stage2
	$(info Restore ROOT from ${STAGE2})
	@rm -rf ${ROOT}
	@mkdir -p ${ROOT} && cd ${ROOT} && tar xf ${SRC}/${STAGE2}

clean: need-suid ## 🧹 Delete ROOT
	@rm -rf ${ROOT}

######
## Publishing operations (ssh key restricted)

publish: date := $(shell date +%Y%m%d)
publish:
	rsync -P dyneIV-stage1-amd64.tar dyneIV-stage2-amd64.tar.gz dyneIV-stage3-amd64.tar.gz dyne.files:/srv/ftp/dynebolic/development/
	rsync -P dynebolic.iso dyne.files:/srv/ftp/dynebolic/development/dyneIV-${date}.iso
	ssh dyne.files 'cd /srv/ftp/dynebolic/development && ln -sf dyneIV-${date}.iso dyneIV-latest.iso && sha512sum *iso *tar* | grep -v latest | tee SHA512SUMS.txt'

rsync-server: tmp := $(shell mktemp)
rsync-server: here := $(shell pwd)
rsync-server:
	cp rsync.conf ${tmp}
	echo "  path = ${here}" >> ${tmp}
	rsync --daemon --verbose --no-detach --config ${tmp}
