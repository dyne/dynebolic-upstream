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


SRC=$(shell dirname $(shell pwd))

.SECONDEXPANSION:
all: squash iso

include ${SRC}/config.mk

squash: need-suid static-overlay prepare-excludes
	$(if $(wildcard ${ROOT}),,$(error ROOT not found.))
	@rm -f ${SRC}/${STAGE3}
	$(info Squashing dynebolic read-only filesystem)
	$(info Please wait while compressing the filesystem...)
	tar -c --exclude-from=/tmp/dyneIV-excludes ${ROOT} \
		| pv -p -s `du -sb ${ROOT} | awk '{print $$1}'` \
	    | tar2sqfs -r ${ROOT} -x -f -q -c xz -X level=9 ${SRC}/${STAGE3}

# mksquashfs ${ROOT} ${SRC}/${STAGE3} \
# -comp xz -not-reproducible \
# -mkfs-time now -all-time now -root-time now \
# -exports -ef ${SRC}/excludes-filesystem.txt -wildcards \
# -one-file-system -no-xattrs -progress -throttle 80 \
# -noappend -Xbcj x86

iso: need-suid
	$(info Toast the ISO file to dynebolic.iso)
	mkdir -p staging/EFI/BOOT
	mkdir -p staging/boot/grub/x86_64-efi
	mkdir -p staging/isolinux
	mkdir -p staging/live
	rsync -P ${SRC}/${STAGE3} staging/live/filesystem.squashfs
	cp -f ${ROOT}/boot/vmlinuz-* staging/live/vmlinuz
	cp -f ${ROOT}/boot/initrd.img-* staging/live/initrd
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
	xorriso -as mkisofs -iso-level 3 -o "${SRC}/dynebolic.iso"					\
		-full-iso9660-filenames -volid "DYNEIV" --mbr-force-bootable	\
		-partition_offset 16 -joliet -joliet-long -rational-rock		\
		-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -eltorito-boot	\
		isolinux/isolinux.bin -no-emul-boot -boot-load-size 4			\
		-boot-info-table --eltorito-catalog isolinux/isolinux.cat		\
		-eltorito-alt-boot -e --interval:appended_partition_2:all::		\
		-no-emul-boot -isohybrid-gpt-basdat -append_partition 2			\
		C12A7328-F81F-11D2-BA4B-00A0C93EC93B							\
		staging/efiboot.img staging
