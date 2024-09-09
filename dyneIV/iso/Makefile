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

include ${SRC}/config.mk

.SECONDEXPANSION:
all: iso

# needs COMPONENTS to be set (in config.mk)
iso-staging:
	$(info Initializing ISO staging environment)
	@rm -rf staging
	@mkdir -p staging/EFI/BOOT
	@mkdir -p staging/boot/grub/x86_64-efi
	@mkdir -p staging/isolinux
	@mkdir -p staging/live
	@for i in ${COMPONENTS}; do \
		if [ -r ${SRC}/build/dyneIV-$$i-amd64.squashfs ]; then \
			ln -f ${SRC}/build/dyneIV-$$i-amd64.squashfs staging/live/ ;\
			echo dyneIV-$$i-amd64.squashfs | tee -a staging/live/filesystem.module ;\
		fi ;\
	done
	@cp -f ${ROOT}/boot/vmlinuz-* staging/live/vmlinuz
	@cp -f ${ROOT}/boot/initrd.img-* staging/live/initrd
	@cp -f isolinux.cfg staging/isolinux/
	@cp -f grub.cfg staging/boot/grub/
	@cp -f grub.cfg staging/EFI/BOOT
	@cp -f /usr/lib/ISOLINUX/isolinux.bin staging/isolinux/
	@cp -f /usr/lib/syslinux/modules/bios/* staging/isolinux/
	@cp -rf /usr/lib/grub/x86_64-efi/* staging/boot/grub/x86_64-efi/

iso-checksum:
	$(info Please wait while computing SHA256 integrity hash sums)
	@cd staging/live && sha256sum * >sha256sums.txt

grub-check:
	$(info Check grub configuration syntax)
	@grub-script-check grub.cfg

grub-make:
	$(info Build the Grub configuration to boot)
	@grub-mkstandalone -O i386-efi \
		--modules="${grub-mods}" \
		--locales="" --themes="" --fonts=""	\
		--output="staging/EFI/BOOT/BOOTIA32.EFI"				 \
		"boot/grub/grub.cfg=grub-embed.cfg"
	@grub-mkstandalone -O x86_64-efi \
		--modules="${grub-mods}" \
		--locales="" themes="" fonts="" \
		--output="staging/EFI/BOOT/BOOTx64.EFI"						\
	    "boot/grub/grub.cfg=grub-embed.cfg"


squash-static:
	$(info Squash static to ${SRC}/build/dyneIV-static-${ARCH}.squashfs)
	@mkdir -p ${SRC}/build
	@tar -c --exclude ${SRC}/static/home --exclude ${SRC}/static/root  \
		--owner 0:0 ${SRC}/static \
        | tar2sqfs -r ${SRC}/static -f -q ${SQFSCONF} \
            "${SRC}/build/dyneIV-static-${ARCH}.squashfs"
	@echo "--\n-- Done: ${SRC}/build/dyneIV-static-${ARCH}.squashfs\n--"

# requires iso-*-staging before
iso: ISO ?= dynebolic.iso
iso: grub-mods := linux normal search png gfxmenu part_gpt part_msdos fat iso9660
iso:
	$(info Toast the ISO file to ${ISO})
	@cd staging && dd if=/dev/zero of=efiboot.img bs=1M count=20 &&		\
		mkfs.vfat efiboot.img && mmd -i efiboot.img ::/EFI ::/EFI/BOOT &&	\
		mcopy -vi efiboot.img												\
    "EFI/BOOT/BOOTIA32.EFI"					\
    "EFI/BOOT/BOOTx64.EFI"					\
    "boot/grub/grub.cfg" ::/EFI/BOOT/
	@xorriso -as mkisofs -iso-level 3 -o "${SRC}/${ISO}"			\
		-full-iso9660-filenames -volid "DYNEIV" --mbr-force-bootable	\
		-partition_offset 16 -joliet -joliet-long -rational-rock		\
		-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -eltorito-boot	\
		isolinux/isolinux.bin -no-emul-boot -boot-load-size 4			\
		-boot-info-table --eltorito-catalog isolinux/isolinux.cat		\
		-eltorito-alt-boot -e --interval:appended_partition_2:all::		\
		-no-emul-boot -isohybrid-gpt-basdat -append_partition 2			\
		`cat /proc/sys/kernel/random/uuid` \
		staging/efiboot.img staging

iso-snapshot: ISO ?= dynebolic-snapshot.iso
iso-snapshot: grub-mods := linux normal search png gfxmenu part_gpt part_msdos fat iso9660
iso-snapshot: need-suid iso-staging grub-check grub-make
	$(if $(wildcard ${FILE}),,$(error Snapshot not found: ${FILE}))
	$(info Toast the temporary snapshot test ISO file to ${ISO})
	@ln -f ${FILE} staging/live/ && echo "$(notdir ${FILE})" \
		| tee -a staging/live/filesystem.module
	@cd staging && ls -lh live && \
		dd if=/dev/zero of=efiboot.img bs=1M count=20 &&		\
		mkfs.vfat efiboot.img && mmd -i efiboot.img ::/EFI ::/EFI/BOOT &&	\
		mcopy -vi efiboot.img												\
    "EFI/BOOT/BOOTIA32.EFI"					\
    "EFI/BOOT/BOOTx64.EFI"					\
    "boot/grub/grub.cfg" ::/EFI/BOOT/
	@xorriso -as mkisofs -iso-level 3 -o "${SRC}/${ISO}"			\
		-full-iso9660-filenames -volid "DYNEIV" --mbr-force-bootable	\
		-partition_offset 16 -joliet -joliet-long -rational-rock		\
		-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -eltorito-boot	\
		isolinux/isolinux.bin -no-emul-boot -boot-load-size 4			\
		-boot-info-table --eltorito-catalog isolinux/isolinux.cat		\
		-eltorito-alt-boot -e --interval:appended_partition_2:all::		\
		-no-emul-boot -isohybrid-gpt-basdat -append_partition 2			\
		`cat /proc/sys/kernel/random/uuid` \
		staging/efiboot.img staging

#  --install-modules="${grub-install-modules}"
#iso: grub-install-modules := linux normal iso9660 memdisk search tar ls png gfxmenu
# iso: grub-theme := iso/grub-theme/catppuccin-frappe-grub-theme
