#!/bin/sh
#
# dyne:bolic Multiuser mode script
#
# Copyright (C) 2001-2002 Denis Rojo <jaromil@dyne.org>
#
# This source code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Public License as published 
# by the Free Software Foundation; either version 2 of the License,
# or (at your option) any later version.
#
# This source code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# Please refer to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, write to:
# Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA

source /lib/libdyne.sh

# does the CD usrfs has been mounted correctly?
if test -x /usr/sbin/pcimodules; then
    
    dyne_init_boot
    
# launch harddisk detection
# (also fills the WMaker dock configuration)
    /usr/etc/rc.harddisk
    
    sync
        
    if [ -z "`uname -a | grep xbox`" ]; then 
  # if it's not an XBOX detect more devices
	
  # detect extra cds & burners
	/usr/etc/rc.cdrom
	
	sync
	
  # detect floppy drives
	/usr/etc/rc.floppy
	
	sync
	
    fi

# detect usbkey
    /usr/etc/rc.usbkey
    
    sync
    
# echo "[*] Launcing automounter daemon"
    echo -n "[*] "
    /usr/sbin/autofs start
    
    sync
    
# scan for nests
    /usr/etc/rc.nest
    
# if no nest was found then use a virtual filesystem in RAM
    if [ ! -e /boot/nest ]; then
	/usr/etc/rc.vfs
    fi    

    sync
    
# detect xbox
# in case we're on xbox then executes just the
# script for it, avoiding modules detection and
# pcmcia and power management etc...
    if [ ! -z "`uname -a | grep xbox`" ]; then
  # this is a customized configure file for XBOX
  # it loads the needed modules
	/usr/etc/rc.xbox
	
    else
	
# configure pcmcia cards
	/usr/etc/rc.pcmcia start
	
	sync
	
# load necessary kernel modules
	/usr/etc/rc.modules
	
# load appropriate power management system
# DEACTIVATED by jaromil on 4 july 2003 (1.0 beta devel)
# /usr/etc/rc.powman
	
    fi
        
# detect and mount swap partitions
    /usr/etc/rc.swap
   
    sync

# configure mouse
    /usr/etc/rc.mouse
    
    sync
    
# configure videocard
    /usr/etc/rc.vga
    
    sync
    
# configure network
    /usr/etc/rc.net
    
    sync

# configure firewire
    /usr/etc/rc.firewire

    sync

# configure language
    /usr/etc/rc.language
    
    sync
    
# configure ssh client
    /usr/etc/rc.ssh
    
    sync
    
# configure cups daemon
    /usr/etc/rc.cupsd
    
    sync
    
# start samba services
    /usr/etc/rc.samba
    
    sync
    
# start http boa daemon
    /usr/etc/rc.httpd
    
    sync
    
# configure your sound card
    /usr/etc/rc.sound
    
    dyne_close_boot
    
else # the usrfs has not been mounted correctly
    
    sync
    
    error "[!] Cannot mount /usr, falling down to reduced shell, sorry!"
    error "[!] Please report the problem and your system configuration"
    error "[!] to the support mailinglist <dynebolic@dyne.org>."
    /bin/zsh
    
fi
    
