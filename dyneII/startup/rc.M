#!/bin/sh --no-zle
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
# $Id: rc.M,v 1.10 2005/04/22 08:54:17 jaromil Exp $

source /lib/dyne/utils.sh

source /boot/dynenv

######## HOME IS MOUNTER HERE
############ ALL MEDIA MOUNTED, now MOUNT dynebol.sys
##### UNLESS VOLATILE MODE :
VOLATILE="`get_config volatile`"
if [ $VOLATILE ]; then
    # stay into the ramdisk shell
    # for the volatile mode activable at boot prompt
    notice "VOLATILE MODE :: opening a shell in dyne:bolic ramdisk"
    act "you are entering a mantainance sector, whatever that means ;)"

    touch /tmp/volatile

    ## setup the interactive shell prompt
    if [ -r /etc/zshrc ]; then rm /etc/zshrc; fi

    cat > /etc/zshrc <<EOF
    echo "dyne:bolic volatile shell environment"
    echo "this shell is in the ramdisk"
    echo "this is the moment before mounting the /usr system"
    echo
    echo "you are floating in limbo"
    echo
    echo "available commands:"
    echo "ee - text editor"
    echo "insmod - see modules in /boot"
    echo "ifconfig and pump - configure network"
    echo "ncftpget - ftp download"
    echo "rsync - incremental update"
    echo "grep and awk - wild script"
    echo "happy hacking ;)"
EOF
    
    exit 0
fi



# if the system has been allready mounted you can go on
if [ ! -x /usr/bin/mufhd0 ]; then

    if [ -r ${DYNE_SYS_MNT}/dynebol.sys ]; then # for compatibility
	mount -o loop -t squashfs ${DYNE_SYS_MNT}/dynebol.sys /usr
    elif [ -r ${DYNE_SYS_MNT}/dyne/dynebol.sys ]; then
	mount -o loop -t squashfs ${DYNE_SYS_MNT}/dyne/dynebol.sys /usr
    fi

    if [ $? != 0 ]; then # if we cannot mount
	echo
	error "A problem occurred while mounting the dynebol.sys"
	error "dynebolic found a corrupted dynebol.sys on ${DYNE_SYS_DEV}"
	if [ $DYNE_SYS_MEDIA == cdrom ]; then
	    error "it looks like your CDROM is corrupted!"
	fi
	if [ $DYNE_SYS_MEDIA == dvd ]; then
	    error "it looks like your DVD is corrupted!"
	fi
	error "burn your dyne:bolic more carefully"
	error "refer to the USER UPDATED FAQ"
	error "on the wiki pages on lab.dyne.org/DyneBolicFAQ for some tips"
	error "may the source be with you :^)"
	
	echo; echo;
	sleep 10
    fi
    
    if [ ! -x /usr/bin/mufhd0 ]; then
	# no system found on any harddisk or cdrom
	error "No dyne:bolic system has been found on any cdrom or harddisk"
	error "check your harddisk dock or CD: no /dyne directory is present."
	touch /tmp/volatile
	exit 0;
    else
	notice "dynebolic system on ${DYNE_SYS_DEV} mounted in ${DYNE_SYS_MNT}"
    fi
	
fi

export PATH=$PATH:/usr/bin:/usr/sbin


######### TODO:
###### all the /usr/etc/rc.* scripts need to be rewritten
###### they will all be moved in ramdisk (r/w)
###### daemons and network services will be managed by a start-stop mechanism

# configure language
/usr/etc/rc.language

act "dyne:bolic setup on `date`" >> $LOG
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

#act "reset boot log file in /var/log"
#if [ -r /var/log/dynebolic.log ]; then
#  rm /var/log/dynebolic.log
#fi
#mv ${LOG} /var/log/dynebolic.log

notice "setup network loopback device"
ifconfig lo 127.0.0.1

echo -n "[*] "; /usr/sbin/autofs start

# detect and mount swap partitions
/usr/etc/rc.swap &

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
    
# load necessary kernel modules
    /usr/etc/rc.modules
    
# load appropriate power management system
# DEACTIVATED by jaromil on 4 july 2003 (1.0 beta devel)
# /usr/etc/rc.powman
    
fi


# configure videocard
/usr/etc/rc.vga

# configure mouse
# now is all compiled into the kernel
/usr/etc/rc.mouse

# configure your sound card
/usr/etc/rc.sound

# configure firewire
/usr/etc/rc.firewire

# configure network
/usr/etc/rc.net

# launch daemons in sequence

# configure ssh client
/usr/etc/rc.ssh &

# configure cups daemon
/usr/etc/rc.cupsd &

# start samba services
/usr/etc/rc.samba &

# start pure ftp daemon
/usr/etc/rc.ftp &

# start http boa daemon
/usr/etc/rc.httpd &

# configure your mail transport
/usr/etc/rc.mail &

# configure openmosix clustering
/usr/etc/rc.mosix

# link the extras in the home
if [ ! -r /home/extras ]; then
  source /boot/dynenv
  if [ -r /mnt/dynebolic/extras ]; then
    act "linking extras in home"
    ln -s /mnt/dynebolic/extras /home/extras
  fi
fi


# execute rc.local if present
# you can create rc.local in the /etc directory
# and put there the commands to be executed here
# you can also put it in a floppy a:\dynebol.sh
# and then uncomment the proper lines in /etc/rc.S
if [ -e /etc/rc.local ]; then
  /etc/rc.local
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

sync

