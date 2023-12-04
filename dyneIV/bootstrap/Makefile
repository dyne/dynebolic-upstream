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
MODE ?= root
VARIANT ?= apt
# essential, minbase
FORMAT ?= dir

all: base linux-libre live-boot xorg shrink squash

# dependencies needed to build a live system
deps:
	dpkg -i devuan-keyring_2023.05.28_all.deb
	apt-get install mmdebstrap squashfs-tools xorriso isolinux			\
    syslinux syslinux-efi syslinux-common syslinux-utils grub-pc-bin	\
    grub-efi-amd64-bin grub-efi-ia32-bin mtools dosfstools				\
    squashfs-tools-ng pv

base:
	 mmdebstrap \
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
		--include='ca-certificates locales apt-transport-https curl apt-utils' \
		--comp=main --arch=${ARCH} \
	daedalus ROOT http://deb.devuan.org/merged

linux-libre:
	@echo "Install linux-libre"
	@wget https://linux-libre.fsfla.org/pub/linux-libre/freesh/pool/main/f/freesh-archive-keyring/freesh-archive-keyring_1.1_all.deb
	@mv freesh-archive-keyring_1.1_all.deb ROOT/
	chroot ROOT dpkg -i /freesh-archive-keyring_1.1_all.deb && rm -f ROOT/freesh-archive-keyring_1.1_all.deb
	chroot ROOT apt-get update
	chroot ROOT apt-get -q -y install linux-libre-6.1*

live-boot:
	chroot ROOT apt-get -q -y install mount live-boot zstd \
		openrc sysvinit-core psmisc e2fsprogs orphan-sysvinit-scripts
	chroot ROOT echo 'root:luther' | chpasswd
	chroot ROOT locale-gen --purge en_US.UTF-8
	chroot ROOT echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' \
				> /etc/default/locale
	chroot ROOT echo "dynebolic" > /etc/hostname
	chroot ROOT update-initramfs -k all -c

xorg:
	@echo "Install X11"

	chroot ROOT apt-get -q -y install xserver-xorg-core xserver-xorg	\
		xinit xterm xnest xserver-xorg-video-dummy openbox x11vnc		\
		x11-utils mesa-utils desktop-base devuan-baseconf deepsea-icon-theme

	@echo " install headless driver"
	chroot ROOT echo "exec openbox-session" > /etc/X11/xinitrc

#	cp -f xorg-headless.conf ROOT/etc/X11/xorg.conf.d/10-headless.conf


squash: SIZE := $(shell du -sk ROOT | cut -f 1)
squash:
	@echo "Squash ROOT to dynebolic.squash"
	-[ -r ROOT/boot ] && mv -v ROOT/boot .
	tar c ROOT | pv -p -s ${SIZE}k \
		| tar2sqfs -r ROOT -x -f -q -c zstd dynebolic.squash
	-[ -r boot ] && mv -f boot ROOT/

shrink:
	rm -rvf ROOT/usr/share/gtk-doc/*
	rm -rvf ROOT/usr/share/man/*
	rm -rvf ROOT/usr/share/help/*
	rm -rvf ROOT/usr/share/info/*
	rm -rvf ROOT/usr/share/doc/*
	-find ROOT/ -type d -name '__pycache__' -exec rm -rvf {} \;
	-find ROOT/var/log/ -type f -name '*.log' -exec rm -rvf {} \;
	rm -rvf ROOT/var/tmp/*
	chroot ROOT apt-get autoremove
	chroot ROOT apt-get clean

toast:
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
	qemu-system-x86_64 -enable-kvm -cdrom dynebolic.iso -m 2048 -smp	\
	4 -device intel-hda -device hda-duplex -device						\
	nec-usb-xhci,id=usb -chardev										\
	spicevmc,name=usbredir,id=usbredirchardev1 -device					\
	usb-redir,chardev=usbredirchardev1,id=usbredirdev1 -chardev			\
	spicevmc,name=usbredir,id=usbredirchardev2 -device					\
	usb-redir,chardev=usbredirchardev2,id=usbredirdev2 -chardev			\
	spicevmc,name=usbredir,id=usbredirchardev3 -device					\
	usb-redir,chardev=usbredirchardev3,id=usbredirdev3

clean:
	rm -rf ROOT staging

# > dynebolic-stage1.tar
# @ls -lh dynebolic-stage1.tar
# @echo "Squashing filesystem..."
# @rm -f dynebolic-stage1.squash
# cat dynebolic-stage1.tar | tar2sqfs -q -c zstd dynebolic-stage1.squash
# @ls -lh dynebolic-stage1.squash
# @rm -f dynebolic-stage1.tar

#		--hook-dir=/usr/share/mmdebstrap/hooks/no-merged-usr \

#		--include freesh-archive-keyring_1.1_all.deb \

