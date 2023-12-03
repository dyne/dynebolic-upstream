
# Run as root

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
    squashfs-tools-ng

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
	chroot ROOT apt-get -q -y install mount live-boot zstd
	chroot ROOT update-initramfs -k all -c

xorg:
	@echo "Install X11"
	chroot ROOT apt-get -q -y install xserver-xorg-core xserver-xorg xinit xterm xnest xserver-xorg-video-dummy openbox
	@echo " install headless driver"
	@cp xorg-headless.conf ROOT/etc/X11/xorg.conf.d/10-headless.conf

# lxqt:
# 	@echo "Install LXQT"
# 	chroot ROOT apt-get -q -y --no-install-recommends install lxqt

squash:
	@echo "Squash ROOT in compressed form"
	-[ -r ROOT/boot ] && mv ROOT/boot .
	cd ROOT && tar c * | tar2sqfs -c zstd ../dynebolic.squash

shrink:
	rm -rvf ROOT/usr/share/gtk-doc/*
	rm -rvf ROOT/usr/share/man/*
	rm -rvf ROOT/usr/share/help/*
	rm -rvf ROOT/usr/share/info/*
	rm -rvf ROOT/usr/share/doc/*
	-find ROOT/ -type d -name '__pycache__' -exec rm -rvf {} \;
	-find ROOT/var/log/ -type f -name '*.log' -exec rm -rvf {} \;
	rm -rvf ROOT/var/tmp/*
	chroot ROOT apt-get clean

toast:
	mkdir -p staging/EFI/BOOT
	mkdir -p staging/boot/grub/x86_64-efi
	mkdir -p staging/isolinux
	mkdir -p staging/live
	-[ -r dynebolic.squash ] && mv dynebolic.squash staging/live/filesystem.squashfs
	[ -r staging/live/filesystem.squashfs ] || exit 1
	cp boot/vmlinuz-* staging/live/vmlinuz
	cp boot/initrd.img-* staging/live/initrd
	cp isolinux.cfg staging/isolinux/
	cp grub.cfg staging/boot/grub/
	cp grub.cfg staging/EFI/BOOT
	cp /usr/lib/ISOLINUX/isolinux.bin staging/isolinux/
	cp /usr/lib/syslinux/modules/bios/* staging/isolinux/
	cp -r /usr/lib/grub/x86_64-efi/* staging/boot/grub/x86_64-efi/
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

