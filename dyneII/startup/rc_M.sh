#!/bin/zsh --no-zle
#
# dyne:bolic hardware setup script
# run after system detect
#
# copyleft 2001 - 2005 jaromil @ dyne.org
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

if [ -z $INIT_VERSION ]; then
  error "This file is part of dyne system startup sequence"
  error "and should be only run by the init(1) process"
  exit -1
fi

source /lib/dyne/modules.sh

source /boot/dynenv

######## HOME IS MOUNTER HERE
############ ALL MEDIA MOUNTED, now MOUNT dyne.sys
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
    echo "zile - emacs like text editor"
    echo "insmod - see modules in /boot/modules"
    echo "ifconfig and dhcpcd - configure network"
    echo "ncftpget - FTP download tool"
    echo "rsync - incremental update from network"
    echo "grep, sed and awk - wild scripting"
    echo "samba filesystem is supported as well"
    echo "happy hacking ;)"
EOF
    
    exit 0
else
    rm /tmp/volatile
fi



# if the system has been allready mounted you can go on
if [ "$DYNE_SYS_MEDIA" = "pre_mounted" ]; then
    notice "dyne system on ${DYNE_SYS_DEV} mounted in ${DYNE_SYS_MNT}"
else

    if [ -x ${DYNE_SYS_MNT}/dyne/SDK/sys/bin/dynesplash ]; then

	notice "Mounting SDK filesystem from dock in ${DYNE_SYS_MNT}"
	mount -o bind ${DYNE_SYS_MNT}/dyne/SDK/sys /usr

    elif [ -r ${DYNE_SYS_MNT}/dyne/dyne.sys ]; then

        if ! [ -x /mnt/usr ]; then mkdir -p /mnt/usr; fi
	mount -o loop -t squashfs ${DYNE_SYS_MNT}/dyne/dyne.sys /mnt/usr
	# load union filesystem module from inside the squash
	insmod /mnt/usr/lib/modules/`uname -r`/kernel/fs/unionfs.ko
        # mount read-only /usr into /mnt/usr
	mount -t unionfs -o dirs=/mnt/usr=ro unionfs /usr
	# writable union will be mounted later on...
	UNION_USR_RW=/var/cache/union/usr_rw

    fi

    if ! [ -x /usr/bin ]; then # if we cannot mount
	echo
	error "A problem occurred while mounting the dyne.sys"
	error "corrupted dyne.sys on ${DYNE_SYS_DEV}"
	if [ "$DYNE_SYS_MEDIA" = "cdrom" ]; then
	    error "it looks like your CDROM is corrupted!"
	fi
	if [ "$DYNE_SYS_MEDIA" = "dvd" ]; then
	    error "it looks like your DVD is corrupted!"
	fi
	error "burn your dyne:bolic more carefully"
	error "refer to the USER UPDATED FAQ"
	error "on the wiki pages on lab.dyne.org/DyneBolicFAQ for some tips"
	error "may the source be with you :^)"
	echo; echo;
	# no system found on any harddisk or cdrom
	error "No dyne:bolic system has been found on any cdrom or harddisk"
	error "check your harddisk dock or CD: no /dyne directory is present."
	touch /tmp/volatile
	exit 0;
    fi
fi

##########################################
# WE'RE in MULTI USER now!

# now the system is mounted expand our PATH
export PATH=$PATH:/usr/bin:/usr/sbin:/usr/X11R6/bin

# configure languages
/etc/init.d/rc.language

# create a /tmp directory
chmod a+w /tmp # world writable tmp
chmod +t /tmp  # sticky bit

# secure the /root hideout
chown root:root /root
chmod go-rwx /root


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

act "network loopback device"
ifconfig lo 127.0.0.1

# deactivated automount
# echo -n "[*] "; /etc/init.d/rc.autofs start

# detect and mount swap partitions
for gh in `fdisk -l | grep -iE "linux.*swap*" | awk '{print $1}'`; do
    act "activating swap partition $gh"
    append_line /etc/fstab "$gh\tswap\tswap\tsw\t0\t0"
    swapon $gh
done


# detect xbox
# in case we're on xbox then executes just the
# script for it, avoiding modules detection and
# pcmcia and power management etc...
if [ ! -z "`uname -a | grep xbox`" ]; then

  # this is a customized configure file for XBOX
  # it loads the needed modules
  /etc/init.d/rc.xbox

else # not an xbox
    
# configure pcmcia cards
  /etc/init.d/rc.pcmcia start
    
# load necessary kernel modules
  /etc/init.d/rc.modules
    
fi


# configure videocard
/etc/init.d/rc.vga

# configure your sound card
/etc/init.d/rc.sound

# configure firewire
/etc/init.d/rc.firewire

# configure network
/etc/init.d/rc.net

if [ ${UNION_USR_RW} ]; then
  notice "making /usr writable with unionfs"
  # create directory where to store unionfs changes
  mkdir -p /var/cache/union/usr_rw
  # assign /usr writable union to /var/cache/union/usr_rw
  /usr/sbin/unionctl /usr --add --before /mnt/usr \
                     --mode rw /var/cache/union/usr_rw
fi


##########################################
## activate all dyne modules
## looks into dyne/modules
## or in dyne/SDK/modules if sdk=true
notice "activating additional dyne modules"

mount_compressed_modules
# see /lib/dyne/modules.sh



##########################################
## starting daemons here

notice "launching device filesystem daemon"
/sbin/udevd &

notice "launching system logging daemon"
/usr/sbin/syslogd

notice "launching common unix printer daemon"
/usr/sbin/cupsd




# execute rc.local if present
# you can create rc.local in the /etc directory
# and put there the commands to be executed here
# you can also put it in a floppy a:\dyne.sh
# and then uncomment the proper lines in /etc/rc.S
if [ -e /etc/rc.local ]; then
  source /etc/rc.local
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

