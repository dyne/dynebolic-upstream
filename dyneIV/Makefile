
.PHONY: bootstrap packages iso

SRC=$(shell pwd)

help:
	@awk 'BEGIN {FS = ":.*##"; printf "🛟 Usage:\n   make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5)} ' Makefile


include config.mk

----: ## Quick test on emulator:

sync: ## 📥 Sync latest online development ISO
	rsync -PL files.dyne.org::dynebolic/dyneIV-latest.iso dynebolic.iso

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

persistence: NBD ?= 14
persistence: need-suid ## 💾 Create persistance storage for qemu
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

clean: ## 🧹 Cleanup all build results
	@make -C bootstrap clean
	@make -C packages clean


#	dpkg -i devuan-keyring_2023.05.28_all.deb
