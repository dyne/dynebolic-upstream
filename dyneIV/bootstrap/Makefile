# Copyright (C) 2023 Dyne.org Foundation
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

# sudo make

# [optional] sudo chroot ROOT (r/w)
# [optional] squashfuse dynebolic.squash /mnt (r/o)
# [optional] sudo chroot /mnt (r/o)
# [optional] umount /mnt

# make toast
# ls -lh dynebolic.iso

ARCH ?= amd64
MODE ?= unshare
VARIANT ?= apt
FORMAT ?= tar

# ARCH ?= amd64
# MODE ?= root
# VARIANT ?= apt

# essential, minbase

UID := $(shell id -u)
PWD := $(shell pwd)

define chroot-script
	@if ! [ -r "${1}" ]; then echo "Install script not found: ${1}"; exit 1; fi
	@echo "--"
	@echo "-- Exec ${1}"
	@cp    "${1}" ROOT/
	@chroot ROOT sh "/${1}"
	@rm -f "ROOT/${1}"
	@echo "-- Done ${1}"
	@echo "--\n"
endef

# second expansion is needed to get the value of
# $(installs) after the whole file was preprocessed
.SECONDEXPANSION:
all: bootstrap $${installs} shrink squash iso

install: $${installs}

need-root:
ifneq (${UID}, 0)
	@echo "Run as root." && exit 1
endif

# local system dependencies needed to build a live system
development-deps: need-root
	$(info Install all development dependencies)
	dpkg -i devuan-keyring_2023.05.28_all.deb
	apt-get install mmdebstrap squashfs-tools xorriso isolinux			\
    syslinux syslinux-efi syslinux-common syslinux-utils grub-pc-bin	\
    grub-efi-amd64-bin grub-efi-ia32-bin mtools dosfstools				\
    squashfs-tools-ng pv schroot uidmap

bootstrap: OUTFILE ?= dyneIV-bootstrap
bootstrap: need-root
	@if [ -r ${OUTFILE}-${ARCH}.tar ]; then \
	 echo "Bootstrap found: ${OUTFILE}-${ARCH}.tar "; \
	else \
	 echo "Bootstrap a new system: dyneIV-bootstrap-${ARCH}.tar"; \
	 UNSHARE_USERS=1 mmdebstrap \
		--mode=${MODE} --variant=${VARIANT} --format=${FORMAT} \
		--aptopt='Apt::Install-Recommends "false"' \
		--aptopt='APT::Install-Suggests "false"' \
		--aptopt='Acquire::Retries "5"' \
		--dpkgopt='path-exclude=/usr/share/doc/*' \
		--essential-hook='echo tzdata tzdata/Areas select Europe | chroot "$$1" debconf-set-selections' \
		--essential-hook='echo tzdata tzdata/Zones/Europe select Amsterdam | chroot "$$1" debconf-set-selections' \
		--hook-dir=/usr/share/mmdebstrap/hooks/eatmydata \
		--hook-dir=/usr/share/mmdebstrap/hooks/file-mirror-automount \
		--include='devuan-keyring' \
		--include='ca-certificates locales apt-transport-https curl apt-utils netcat-openbsd' \
		--comp=main --arch=${ARCH} \
	 daedalus dyneIV-bootstrap-${ARCH}.tar http://deb.devuan.org/merged; \
	fi
	@if [ -r ROOT ]; then \
	 echo "ROOT found, delete to rewind at start."; \
	else \
	 mkdir -p ROOT && cd ROOT && sudo tar xf ../${OUTFILE}-${ARCH}.tar; \
	fi

# setup a local apt-proxy cache
apt-proxy: need-root
	@echo 'Acquire::http::ProxyAutoDetect "/etc/apt/detect-http-proxy.sh";'\
		> ROOT/etc/apt/apt.conf.d/30detectproxy
	@cp detect-http-proxy.sh ROOT/etc/apt/ && chmod +x detect-http-proxy.sh
	@chroot ROOT apt-get update -q -y
	@echo "--"
	@echo "-- Add this line to your apt-cache-ng conf:"
	@echo "-- Remap-devuan: deb.devuan.org packages.devuan.org /merged; http://packages.devuan.org/merged/"
	@echo "--\n"

installs += install-locale
install-locale: need-root
	$(call chroot-script,install-locale.sh)

installs += install-kernel-libre
install-kernel-libre: need-root
	$(call chroot-script,install-kernel-libre.sh)

installs += install-users
install-users: need-root
	$(call chroot-script,install-users.sh)

installs += install-live-boot
install-live-boot: need-root
	$(call chroot-script,install-live-boot.sh)

## bare system is complete here

installs += install-utilities
install-utilities: need-root
	$(call chroot-script,install-utilities.sh)

installs += install-xorg
install-xorg: need-root
	$(call chroot-script,install-xorg.sh)

installs += install-audio
install-audio: need-root
	$(call chroot-script,install-audio.sh)


#	@echo " install headless driver"
#	cp -f xorg-headless.conf ROOT/etc/X11/xorg.conf.d/10-headless.conf

desktop:
	$(info Launch the Desktop)
	xhost + local:
	sudo cp desktop.sh ROOT/
	sudo chroot ROOT sh desktop.sh
	sudo rm -f ROOT/desktop.sh

chroot: SCONF := /etc/schroot/chroot.d/dynebolic.conf
chroot:
	@-[ -r /etc/schroot/dyne ] || sh schroot-setup.sh
	@-if ! [ -r ${SCONF} ]; then \
		cp schroot.conf ${SCONF} && echo "directory=${PWD}/ROOT" >> ${SCONF}; fi
	$(info Enter ROOT)
	@schroot -c dyne -u root -d /root

bwrap:
	@command -v bwrap || exit 1
	xhost + local:
	bwrap --bind ROOT / --proc /proc --dev /dev --unshare-user --share-net \
		--uid 0 --gid 0 bash

shrink: need-root
	$(info Shrink the system)
	-find ROOT/ -type d -name '__pycache__' -exec rm -rvf {} \;
	-find ROOT/var/log/ -type f -name '*.log' -exec rm -rvf {} \;
	@rm -rvf ROOT/tmp/* ROOT/var/tmp/*
	@chroot ROOT apt-get autoremove
	@chroot ROOT apt-get clean

# rm -rvf ROOT/usr/share/gtk-doc/*
# rm -rvf ROOT/usr/share/man/*
# rm -rvf ROOT/usr/share/help/*
# rm -rvf ROOT/usr/share/info/*
# rm -rvf ROOT/usr/share/doc/*

squash: need-root
	$(info Squash ROOT to dynebolic.squash)
	@-[ -r ROOT/boot ] && rm -rf boot && mv -v ROOT/boot .
	@sh squash.sh
	@-[ -r boot ] && mv -f boot ROOT/

iso:
	$(info Toast the ISO file to dynebolic.iso)
	mkdir -p staging/EFI/BOOT
	mkdir -p staging/boot/grub/x86_64-efi
	mkdir -p staging/isolinux
	mkdir -p staging/live
	-[ -r dynebolic.squash ] && mv dynebolic.squash staging/live/filesystem.squashfs
	[ -r staging/live/filesystem.squashfs ] || exit 1
	cp -f ROOT/boot/vmlinuz-* staging/live/vmlinuz
	cp -f ROOT/boot/initrd.img-* staging/live/initrd
	cp -f isolinux.cfg staging/isolinux/
	cp -f grub.cfg staging/boot/grub/
	cp -f grub.cfg staging/EFI/BOOT
	cp -f /usr/lib/ISOLINUX/isolinux.bin staging/isolinux/
	cp -f /usr/lib/syslinux/modules/bios/* staging/isolinux/
	cp -rf /usr/lib/grub/x86_64-efi/* staging/boot/grub/x86_64-efi/
	grub-mkstandalone -O i386-efi --modules="part_gpt part_msdos fat iso9660" \
		 --locales="" --themes="" --fonts=""						\
		--output="staging/EFI/BOOT/BOOTIA32.EFI"					\
		"boot/grub/grub.cfg=grub-embed.cfg"
	grub-mkstandalone -O x86_64-efi --modules="part_gpt part_msdos fat iso9660" \
	    --locales="" themes="" fonts=""								\
		--output="staging/EFI/BOOT/BOOTx64.EFI"						\
	    "boot/grub/grub.cfg=grub-embed.cfg"
	cd staging && dd if=/dev/zero of=efiboot.img bs=1M count=20 &&		\
    mkfs.vfat efiboot.img && mmd -i efiboot.img ::/EFI ::/EFI/BOOT &&	\
    mcopy -vi efiboot.img												\
    "EFI/BOOT/BOOTIA32.EFI"					\
    "EFI/BOOT/BOOTx64.EFI"					\
    "boot/grub/grub.cfg" ::/EFI/BOOT/
	xorriso -as mkisofs -iso-level 3 -o "dynebolic.iso"					\
		-full-iso9660-filenames -volid "DYNEIV" --mbr-force-bootable	\
		-partition_offset 16 -joliet -joliet-long -rational-rock		\
		-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -eltorito-boot	\
		isolinux/isolinux.bin -no-emul-boot -boot-load-size 4			\
		-boot-info-table --eltorito-catalog isolinux/isolinux.cat		\
		-eltorito-alt-boot -e --interval:appended_partition_2:all::		\
		-no-emul-boot -isohybrid-gpt-basdat -append_partition 2			\
		C12A7328-F81F-11D2-BA4B-00A0C93EC93B							\
		staging/efiboot.img staging

qemu:
	$(info Launch QEMU emulator on ISO)
	qemu-system-x86_64 -enable-kvm -cdrom dynebolic.iso -m 2048 -smp	\
	4 -device intel-hda -device hda-duplex -device						\
	nec-usb-xhci,id=usb -chardev										\
	spicevmc,name=usbredir,id=usbredirchardev1 -device					\
	usb-redir,chardev=usbredirchardev1,id=usbredirdev1 -chardev			\
	spicevmc,name=usbredir,id=usbredirchardev2 -device					\
	usb-redir,chardev=usbredirchardev2,id=usbredirdev2 -chardev			\
	spicevmc,name=usbredir,id=usbredirchardev3 -device					\
	usb-redir,chardev=usbredirchardev3,id=usbredirdev3

clean: need-root
	$(info Delete everything)
	@rm -rf ROOT staging *.squash *.iso
