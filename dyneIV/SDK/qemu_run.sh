#!/bin/sh

# https://www.spice-space.org/usbredir.html
qemu-system-x86_64 \
    -enable-kvm \
    -cdrom live-sdk/dist/dynebolic_beowulf_3.0.0_amd64-live.iso \
    -m 2048 \
    -smp 4 \
    -device intel-hda -device hda-duplex \
    -device nec-usb-xhci,id=usb \
    -chardev spicevmc,name=usbredir,id=usbredirchardev1 \
    -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \
    -chardev spicevmc,name=usbredir,id=usbredirchardev2 \
    -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \
    -chardev spicevmc,name=usbredir,id=usbredirchardev3 \
    -device usb-redir,chardev=usbredirchardev3,id=usbredirdev3
