#!/bin/zsh --no-zle
#
# dyne:II startup script
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
# this was originally the Bolic1 startup
#
# SEVERAL modifications followed, this file is no more the same but we all
# love to remember where it comesfrom, as here everything gets started :^)
#
# this is the first file executed by the init(8) process
#
# it's mission is to recognize the attached storage devices,
# find the dyne.sys system and mount it in /usr,
# (or setup the standard environment from cd or hd docks)
# and while it seeks for these things, it also detects storage devices.
#
# it tries if any filesystem contains a /dyne directory in the root
# in case there is, dyne.sys is mounted via loopback device on /usr
# the devices are scanned in order: first IDE harddisks, then IDE cdroms,
# (HINT: many other storages for the system may be supported, read further)
#
#
# after this script, init goes to runlevel 2 and executes rc.M
#
#
# if you are concerned about programming style, this file it's a dirty hack.
# but HEY! bash scripting is not meant for elegance anyway.
#
# if you are peeking in here because some people say that dyne:bolic
# is the fastest live-cd around, well that's not the best place where to
# discover why.
#
# the original bolic1 startup was by C1cc10 and Bomboclat
# the dyne:bolic rewrite, docking and nesting was done by Jaromil
# USB storage handling was reenginered by Richard Griffith
#
# A major rewrite followed in 2005
# by Jaromil, after having studied Awk in India
#
# "$Id: rc.S,v 1.20 2005/04/22 08:54:17 jaromil Exp $"


source /lib/dyne/utils.sh

if [ -z $INIT_VERSION ]; then
  error "This file is part of dyne system startup sequence"
  error "and should be only run by the init(1) process"
  exit -1
fi

source /lib/dyne/volumes.sh
source /lib/dyne/nest.sh


##########################
### HERE STARTS THE MAIN()
##########################

if [ -z $PATH ]; then
    export PATH=/bin:/sbin
fi

# wipe out startup logs and files
rm -f /boot/startup.log
rm -f /boot/dynenv
touch /boot/dynenv
rm -f /boot/volumes
rm -f /boot/auto.removable
touch /boot/auto.removable
rm -f /boot/dyne
rm -f /boot/ascii
rm -f /boot/volatile
rm -f /etc/mtab
if [ -x /var/run ]; then
  rm -rf /var/run/*
  touch /var/run/utmp
fi
# create a /tmp directory in ramdisk
mkdir -p /tmp
####


notice "dyne:bolic hardware device detection"
mount /proc
act "`cat /proc/cpuinfo|grep 'model name'|cut -d: -f2`"
act "`cat /proc/cpuinfo|grep 'flags'|cut -d: -f2`"

mount /dev/pts
mount /sys

# check if an usb controller is present
if [ "`cat /proc/pci | grep USB`" ]; then

   notice "USB controller detected"

   # mount the usb device filesystem
   mount /proc/bus/usb
 
   # start loading the usb storage
   loadmod usb-storage
   
   sync

   if [ "`dmesg | grep '^usb-storage: waiting'`" ]; then
     act "waiting for the kernel to scan usb devices"
     while [ -z "`dmesg | grep '^usb-storage: device scan complete'`" ]; do
       sleep 1 # wait that the kernel scans before we scan
     done
   fi

fi

notice "initializing device filesystem"
/sbin/udevstart

notice "scan for storage volumes"
scan_storage

##

notice "scan for cdrom devices"
scan_cdrom

##

notice "Scan for floppy devices"
##### SCAN FLOPPY DISK
if [ "`dmesg |grep ' fd0 '`" ]; then
    add_volume floppy fd0 floppy auto
fi



act "setup filesystem tables"
cp /boot/auto.removable /etc


### now load the module available to ramdisk
## this is useful if we want to mount remote network systems
CFG_MODULES="`get_config modules_ramdisk`" # list of modules (no extension) or 'autodetect' - modules need to be provided in ramdisk
if [ $CFG_MODULES ]; then
    notice "load kernel modules available to ramdisk"

    act "configured kernel modules: ${CFG_MODULES}"

    if [ "`echo $CFG_MODULES |grep -i 'autodetect'`" ]; then
	act "modules autodetection invoked"
	for m in `pcimodules`; do
	    loadmod ${m}
	done
    fi

    for m in `iterate ${CFG_MODULES}`; do
	loadmod ${m}
    done

fi

#### if network boot is configured...
# at this point all modules should be loaded in order to have
# the network card recognized. put needed modules in /boot or in a dock
BOOT_NETWORK="`get_config network_boot`" # "iface ip_address netmask gateway dns" or "dhcp"
if [ $BOOT_NETWORK ]; then

    if [ "`ifconfig -a | grep eth`" ]; then

	notice "Network booting is configured"
	# go for the DHCP auto config
	if [ "`echo $BOOT_NETWORK | grep -iE 'pump|dhcp|auto'`" ]; then

	    act "autodetect dhcp network address"
	    pump

	else

	    IFACE=`echo $BOOT_NETWORK   |awk '{print $1}'`
	    IP=`echo $BOOT_NETWORK      |awk '{print $2}'`
	    NETMASK=`echo $BOOT_NETWORK |awk '{print $3}'`
	    GW=`echo $BOOT_NETWORK      |awk '{print $4}'`
	    DNS=`echo $BOOT_NETWORK     |awk '{print $5}'`
	    ifconfig ${IFACE} ${IP} netmask ${NETMASK}
	    route add default gw ${GW}
	    echo "nameserver $DNS" > /etc/resolv.conf

	fi



#### FTP DOWNLOAD


	DOCK_FTP=`get_config dock_download_ftp` # remote_host remote_dyne_dir local_destination_dir
	if [ $DOCK_FTP ]; then
	    REMOTE_HOST="`echo $DOCK_FTP |awk '{ print $1 }'`"
	    REMOTE_DIR="`echo $DOCK_FTP  |awk '{ print $2 }'`"
	    LOCAL_DIR="`echo $DOCK_FTP   |awk '{ print $3 }'`"
	    notice "Configured to download a dock from ftp://${REMOTE_HOST}/${REMOTE_DIR}"
	    act "will save the dock in $LOCAL_DIR"
	    ncftpget -R $REMOTE_HOST $LOCAL_DIR $REMOTE_DIR
	fi



#### RSYNC UPDATE

	DOCK_RSYNC=`get_config dock_update_rsync` # rsync.host::module/dyne local_destination_dir
	if [ $DOCK_RSYNC ]; then
	    REMOTE_RSYNC="`echo $DOCK_RSYNC |awk '{ print $1 }'`"
	    LOCAL_DIR="`echo $DOCK_RSYNC    |awk '{ print $2 }'`"
	    notice "Upgrading the system from rsync://$REMOTE_RSYNC"
	    act "will save the dock in $LOCAL_DIR"
	    rsync -Pr ${REMOTE_RSYNC} ${LOCAL_DIR}
	fi




#### SAMBA REMOTE DOCKING


	DOCK_SAMBA=`get_config dock_mount_samba` # //network_address/mount (public access)
	if [ $DOCK_SAMBA ]; then
	    notice "Configured to mount samba dock ${DOCK_SAMBA}"
	    loadmod smbfs
	    mount -t smbfs "${DOCK_SAMBA}" "${MNT}"
	    if [ $? != 0 ]; then # mount failed
		error "mount failed, remote dock aborted"
	    else
		if ! [ -r "${MNT}/dyne" ]; then
		    error "no dyne system found on ${DOCK_SAMBA}"
		    unmount ${MNT}
		else
		    DYNE_SYS_MEDIA="samba"
		    DYNE_SYS_MNT="${MNT}"
		    DYNE_SYS_DEV="${DOCK_REMOTE}"
		fi
	    fi
	fi



    else
	error "Can't activate network device: network boot is aborted"
    fi
fi

#### if /usr is not already mounted then let's go looking for a system
#### this control lets have dyne:bolic run from a partition
if [ ! -x /usr/bin/dynesplash ]; then
    

##### NOW HERE THE SYSTEM SELECTION

  # call the procedure to select and upgrade detected systems
  choose_volumes
  # see /lib/dyne/volumes.sh

  choose_nest
  # see /lib/dyne/nest.sh

else

  DYNE_SYS_DEV=`get_config root`
  DYNE_SYS_MNT=/SDK/cdrom
  DYNE_SYS_MEDIA=pre_mounted

fi

# dump what we've found into the dyne environmental conf
echo "# dyne environment" > /boot/dynenv
echo "# this file is generated by the Startup script at every boot" >> /boot/dynenv
#echo "# made on `date`" >> /boot/dynenv
echo "# Startup \$Id: rc.S,v 1.20 2005/04/22 08:54:17 jaromil Exp $" >> /boot/dynenv
#echo "# running on `uname -a`" >> /boot/dynenv
echo >> /boot/dynenv
echo "export DYNE_SYS_DEV=${DYNE_SYS_DEV}"     >> /boot/dynenv
echo "export DYNE_SYS_MEDIA=${DYNE_SYS_MEDIA}" >> /boot/dynenv
echo "export DYNE_SYS_MNT=${DYNE_SYS_MNT}"     >> /boot/dynenv
echo "export DYNE_NEST_VER=${DYNE_NEST_VER}"   >> /boot/dynenv
echo "export DYNE_NEST_PATH=${DYNE_NEST_PATH}" >> /boot/dynenv






exit 0;


