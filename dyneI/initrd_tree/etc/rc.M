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

# does the CD usrfs has been mounted correctly?
if test -x /usr/sbin/pcimodules; then
    
# setup starting volumes id
    if [ -e /boot/wmdock-pos ]; then rm -f /boot/wmdock-pos; fi
    echo "1" > /boot/wmdock-pos
    
# setup WindowMaker dock configuration header
    if [ -e /boot/WMState ]; then rm -r /boot/WMState; fi
    cp /usr/share/dynebolic/templates/WMState.head /boot/WMState
    
    sync
    
# launch harddisk detection
# (also fills the WMaker dock configuration)
    /usr/etc/rc.harddisk
    
    sync
    
# setup the automount configuration template
# auto.removable gets edited by the rc.cdrom, floppy, usbkey 
    if [ -e /etc/auto.removable ]; then rm -f /etc/auto.removable; fi
# in case of nesting this is rescued by /usr/etc/rc.nest
    cp /etc/auto.removable.dist /etc/auto.removable
    
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
    /usr/sbin/autofs start
    
# completing WindowMaker dock configuration footer
    cat /usr/share/dynebolic/templates/WMState.foot >> /boot/WMState
    
    sync
    
# scan for nests
    /usr/etc/rc.nest
    
# if no nest was found then use a virtual filesystem in RAM
    if [ ! -e /boot/nest ]; then
	/usr/etc/rc.vfs
    fi    

# copy the WindowMaker dock configuration in place
    cp /boot/WMState /home/GNUstep/Defaults/WMState

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
    
# setup the fstab configuration template
# fstab gets edited by the rc.swap script
    if [ -e /etc/fstab ]; then rm -f /etc/fstab; fi
    cp /etc/fstab.dist /etc/fstab
    
# detect and mount swap partitions
    /usr/etc/rc.swap
    
# configure mouse
# we don't use anymore gpm
# both serial and ps2 mices are supported from X
#/usr/etc/rc.mouse
    
    sync
    
# configure videocard
    /usr/etc/rc.vga
    
    sync
    
# configure network
    /usr/etc/rc.net
    
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
    
else # the usrfs has not been mounted correctly
    
    sync
    
    echo "[!] Cannot mount /usr, falling down to reduced shell, sorry!"
    echo "[!] Please report the problem and your system configuration"
    echo "[!] to the support mailinglist <dynebolic@dyne.org>."
    /bin/zsh
    
fi
    