#!/bin/sh
set -e
# ensure to be running root
apt-get -q -y install qemu-utils ovmf parted curl

mkdir -p /opt/dynebolic
cd /opt/dynebolic

if ! [ -r dyneIV.iso ]; then
  curl -L https://files.dyne.org/dynebolic/development/dyneIV-latest.iso -o dyneIV.iso
  chmod a+r dyneIV.iso
  chmod go-w dyneIV.iso
fi

NBD="14"

modprobe nbd

if ! [ -r persistence.qcow2 ]; then
  qemu-img create -f qcow2 persistence.qcow2 10G
  qemu-nbd -c /dev/nbd${NBD} persistence.qcow2
  parted -s /dev/nbd${NBD} -- mklabel msdos mkpart primary ext4 1 -1 set 1 boot off
  mkfs.ext4 -L persistence /dev/nbd${NBD}p1
  mkdir -p mnt && mount /dev/nbd${NBD}p1 mnt \
	  && echo "/ union" > mnt/persistence.conf \
	  && umount mnt
  qemu-nbd -d /dev/nbd${NBD}
  chmod a+rw persistence.qcow2
fi

QEMU_CONF="-device intel-hda -device hda-duplex -device nec-usb-xhci,id=usb -chardev spicevmc,name=usbredir,id=usbredirchardev1 -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 -chardev spicevmc,name=usbredir,id=usbredirchardev2 -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 -chardev spicevmc,name=usbredir,id=usbredirchardev3 -device	usb-redir,chardev=usbredirchardev3,id=usbredirdev3"

qemu-system-x86_64 -enable-kvm -bios /usr/share/ovmf/OVMF.fd -cdrom \
dyneIV.iso -hda persistence.qcow2 --boot once=d -m 4096 -smp 4 ${QEMU_CONF}
