#!/bin/zsh

# dyne:II hotplug system
# (C) 2005 Denis "Jaromil" Rojo

# this script makes use of dyne utilities to rescan the usb hosts
# and plug the new scsi disc (usb storage mostly) to the system

source /lib/dyne/utils.sh

# TODO:
# check that in the past happened hotplug event: usb_device
# if dmesg is hanging on "usb-storage: waiting"
# then wait for "usb-storage: device scan complete"
# scan for the new "SCSI device sd*"
# scan for partitions in sd??
# if not partitions present, pick MBR sd?
# if partitions present, pick the first (i.e. sda1)

notice "new storage device plugged"

