#!/bin/sh

# simple script to prepare Live bootable USB sticks
# using GRUB2 (or 1.98 whatever debian ships now)

# ripped from a tutorial/script by Panticz
# maintained for dyneIII by Jaromil
# FWIW, GNU GPL v3

# some documentation links:

# http://www.panticz.de/MultiBootUSB
# http://tails.boum.org/todo/usb_install_and_upgrade/


if [ -z $1 ]; then
    echo "usage: $0 /dev/sdX live-image.iso"
    echo "/dev/sdX device is not a partition"
    exit 1
fi

DEVICE=${1}
VOLUME=dyneIII
MNT=/mnt/1
ISO=`basename ${2}`
ISOPATH=`dirname ${2}`

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
sudo rsync -P ${ISOPATH}/${ISO} ${MNT}

echo "installing grub..."
# install grub2 on usb pen
sudo grub-install --no-floppy --root-directory=${MNT} ${DEVICE}
  
# create grub config
cat <<EOF> /tmp/live-usb-grub.cfg
insmod part_msdos
insmod loopback
insmod iso9660

set menu_color_normal=white/blue
set_menu_color_highlight=blue/light-gray

menuentry "dyne:bolic 3.0" --class gnu-linux --class gnu --class os {
	iso_path=/${ISO}
	export iso_path
	search --set --file \$iso_path
        loopback loop \$iso_path
	root=(loop)
        linux /live/vmlinuz boot=live iso-scan/filename=\$iso_path fromiso=/dev/sdb1\$iso_path noeject noprompt --
        initrd /live/initrd.img
}
EOF
# needs our own modified initrd scripts/live to support VFAT usb sticks
# TODO: test if we can remove or substitute fromiso code in them...
#       also add some goodies to grub

sudo mv /tmp/live-usb-grub.cfg ${MNT}/boot/grub/grub.cfg

# umount
sync
sudo umount ${MNT}

echo "operation successful."
exit 0
 
