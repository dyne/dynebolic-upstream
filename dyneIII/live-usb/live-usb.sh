#!/bin/sh

# simple script to prepare Live bootable USB sticks
# using GRUB2 (or 1.98 whatever debian ships now)

# ripped from a tutorial/script by Panticz
# maintained for dyneIII by Jaromil
# GNU GPL v3

# some documentation links:

# http://www.panticz.de/MultiBootUSB
# https://bugs.launchpad.net/ubuntu/+bug/94204
# http://debianforum.de/forum/viewtopic.php?f=32&t=111249
# http://michael-prokop.at/blog/2009/05/25/boot-an-iso-via-grub2/
# https://wiki.edubuntu.org/Grub2
# http://wiki.ubuntuusers.de/GRUB_2/Konfiguration?highlight=cd


if [ -z $1 ]; then
    echo "usage: $0 /dev/sdX (device)"
    exit 1
fi

DEVICE=${1}
VOLUME=dyneIII
MNT=/mnt/1

if ! [ -r $DEVICE ]; then
    echo "error: device $DEVICE not found"
    exit 1
fi

# create filesystem on usb pen
# sudo mkfs.vfat -n ${VOLUME} ${DEVICE}1

# mount usb
sudo mkdir -p ${MNT}
sudo mount ${DEVICE}1 ${MNT}

if [ $? != 0 ]; then
    echo "error mounting ${DEVICE}1 - operation aborted."
    exit 1
fi

echo "device correctly mounted:"
mount | grep "${DEVICE}"

echo "starting to copy ISO file..."
sudo rsync -P /srv/iso/dyneIII-shareit.iso ${MNT}

echo "installing grub..."
# install grub2 on usb pen
sudo grub-install --no-floppy --root-directory=${MNT} ${DEVICE}
  
# create grub config
cat <<EOF> /tmp/live-usb-grub.cfg
menuentry "dyne:bolic 3.0" {
        loopback loop /dyneIII-shareit.iso
        linux (loop)/live/vmlinuz boot=live iso-scan/filename=/dyneII-shareit.iso noeject noprompt --
        initrd (loop)/live/initrd.img
}
EOF
sudo mv /tmp/live-usb-grub.cfg ${MNT}/boot/grub/grub.cfg

# umount
sync
sudo umount ${MNT}

echo "operation successful."
exit 0
 
