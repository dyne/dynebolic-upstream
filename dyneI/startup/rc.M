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

source /lib/libdyne.sh

if [ -z `mount | grep "type squashfs"` ]; then
    echo
    error "[!] Cannot mount /usr, falling down to reduced shell, sorry!"
    error "[!] Please report the problem and your system configuration"
    error "[!] to the support mailinglist <dynebolic@dyne.org>."
    /bin/zsh
    exit 1
fi


echo "dyne:bolic setup on `date`" >> $LOG
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

notice "activate runtime configurations"
act "windowmaker dock in /home"
if [ -r /home/GNUstep/Defaults/WMState ]; then
    rm -f /home/GNUstep/Defaults/WMState
fi
cp /usr/share/dynebolic/templates/WMState.head /home/GNUstep/Defaults/WMState
cat /boot/WMState >> /home/GNUstep/Defaults/WMState
cat /usr/share/dynebolic/templates/WMState.foot >> /home/GNUstep/Defaults/WMState

act "filesystem table in /etc"
cp /boot/fstab /etc
cp /boot/auto.removable /etc

act "startup log file in /var/log"
mv ${LOG} /var/log
LOG="/var/log/dynebolic.log"


notice "setup network loopback device"
ifconfig lo 127.0.0.1

sync

echo -n "[*] "; /usr/sbin/autofs start

sync

# scan for nests
#/usr/etc/rc.nest
#sync



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

sync

# execute rc.local if present
# you can create rc.local in the /etc directory
# and put there the commands to be executed here
# you can also put it in a floppy a:\dynebol.sh
# and then uncomment the proper lines in /etc/rc.S
if [ -e /etc/rc.local ]; then
  source /etc/rc.local
fi

sync


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

sync

