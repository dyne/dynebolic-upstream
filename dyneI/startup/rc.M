#!/bin/sh
#
# dyne:bolic hardware setup script
# run after system detect
#
# copyleft 2001 - 2004 jaromil @ dyne.org
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
#
# $Id$

if [ -z `mount | grep "type squashfs"` ]; then

    error "[!] Cannot mount /usr, falling down to reduced shell, sorry!"
    error "[!] Please report the problem and your system configuration"
    error "[!] to the support mailinglist <dynebolic@dyne.org>."
    /bin/zsh
    exit 1
fi

source /lib/libdyne.sh

# set to 'true' to not generate the partition icons in the WM dock
# leftover, will be cleaned and set in the config file some time in the future
#STATICWM=true


# bootsequence initialization
# this sets up all kind of configuration files that will be then updated
# upon detection of hardware devices present
init_detect() {

  if [ -z $STATICWM ]; then # STATICWM true: don't generate the dock
# setup starting files
    if [ -e /var/run/WMNum ]; then rm -f /var/run/WMNum; fi
    if [ -e /var/run/WMState ]; then rm -r /var/run/WMState; fi
    cp /usr/share/dynebolic/templates/WMState.head /var/run/WMState
  fi
  
# setup the automount configuration template
# auto.removable gets edited by the rc.cdrom, floppy, usbkey 
    if [ -e /etc/auto.removable ]; then rm -f /etc/auto.removable; fi
# in case of nesting this is rescued by /usr/etc/rc.nest
    cp /usr/share/dynebolic/templates/auto.removable.dist /etc/auto.removable

    echo "dyne:bolic boot starting on `date`" >> $LOG
    echo "$LIBDYNE_ID" >> $LOG
    echo "kernel:`uname -a`" >> $LOG
    echo "CPU:`cat /proc/cpuinfo|grep 'model name'|cut -d: -f2`" >> $LOG
    echo "flags:`cat /proc/cpuinfo|grep 'flags'|cut -d: -f2`" >> $LOG
    echo >> $LOG
    echo "=== devices detected on pci bus:" >> $LOG
    lspci >> $LOG
    echo "===" >> $LOG
    echo >> $LOG
    dmesg -n 1

}

close_detect() {
  if [ -z $STATICWM ]; then
    # completing WindowMaker dock configuration footer
    cat /usr/share/dynebolic/templates/WMState.foot >> /boot/WMState
    # copy the WindowMaker dock configuration in place
    cp /boot/WMState /home/GNUstep/Defaults/WMState
  else
    cp /usr/share/dynebolic/templates/WMState.static \
       /home/GNUstep/Defaults/WMState
  fi

  echo "[*] boot sequence completed on `date`" >> $LOG
  echo >> $LOG
  echo "=== kernel modules loaded:" >> $LOG
  lsmod >> $LOG
  echo "===" >> $LOG
  echo >> $LOG
  echo "=== mounted filesystems:" >> $LOG
  mount >> $LOG
  echo "===" >> $LOG
  echo >> $LOG
}




echo "[*] setup network loopback device"
ifconfig lo 127.0.0.1

# start up the the dynamicly configured files
init_detect

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
# now is all compiled into the kernel
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

sync

# configure openmosix clustering
/usr/etc/rc.mosix

close_detect

sync

