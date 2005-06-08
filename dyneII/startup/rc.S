#!/bin/sh --no-zle
#
# dyne:bolic startup script
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
# find the dynebolic system and mount it in /usr,
# find nests and mount them on /etc and /home
# (or setup the standard environment from cd or hd docks)
# and while it seeks for these things, it also detects storage devices.
#
# it tries if any filesystem contains a /dyne directory in the root
# in case there is, dynebolic.sys is mounted via loopback device on /usr
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
source /lib/dyne/volumes.sh
source /lib/dyne/nest.sh


##########################
### HERE STARTS THE MAIN()
##########################

# should we even be running?
if [ -x /usr/bin/mufhd0 ]; then exit 1; fi

if [ -z $PATH ]; then
    export PATH=/bin:/sbin
fi
 
notice "dyne:bolic hardware device detection"
mount /proc
mount /sys
mount /dev/pts

act "`cat /proc/cpuinfo|grep 'model name'|cut -d: -f2`"
act "`cat /proc/cpuinfo|grep 'flags'|cut -d: -f2`"

notice "starting device filesystem daemon"
echo -n " .  "
/sbin/devfsd /dev

sync


notice "load loopback device kernel module"
echo -n " .  " 
if [ -z "`uname -a | grep xbox`" ]; then
    loadmod loop-aes \
	max_loop=128 lo_prealloc=100,1,500,6,200 lo_nice=-10
else
    loadmod loop-aes-xbox \
	max_loop=128 lo_prealloc=100,1,1000,6,200 lo_nice=-10
fi



notice "scan for harddisk volumes"

scan_harddisk

##

notice "scan for usb storage volumes"

scan_usbstorage

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
cp /boot/fstab /etc
cp /boot/auto.removable /etc


### now load the module available to ramdisk
## this is useful if we want to mount remote network systems
CFG_MODULES="`get_config modules_ramdisk`"
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
BOOT_NETWORK="`get_config network_boot`"
if [ $BOOT_NETWORK ]; then

    if [ "`ifconfig -a | grep eth`" ]; then

	notice "Network booting is configured"
	# go for the DHCP auto config
	if [ "`echo $BOOT_NETWORK | grep -iE 'pump|dhcp|auto'`" ]; then

	    act "autodetect dhcp network address"
	    pump

	else

	# network_boot="iface,ip_address,netmask"
	    IFACE=`echo $BOOT_NETWORK|awk 'BEGIN{FS=","}{print $1}'`
	    IP=`echo $BOOT_NETWORK|awk 'BEGIN{FS=","}{print $2}'`
	    NETMASK=`echo $BOOT_NETWORK|awk 'BEGIN{FS=","}{print $3}'`
	    ifconfig ${IFACE} ${IP} netmask ${NETMASK}

	fi



#### FTP UPDATE

	# dock_upgrade_ftp="network_address remote_dir"
	DOCK_FTP=`get_config dock_upgrade_ftp`
	if [ $DOCK_FTP ]; then
	    REMOTE_HOST="`echo $DOCK_FTP|awk '{ print $1 }'`"
	    REMOTE_DIR="`echo $DOCK_FTP|awk '{ print $2 }'`"
	    notice "Configured to upgrade dock from ftp://${REMOTE_HOST}/${REMOTE_DIR}"
	    notice "TODO"
	fi
	

#### SAMBA REMOTE DOCKING

	# dock_mount_samba="//network_address/mount"
	DOCK_SAMBA=`get_config dock_mount_samba`
	if [ $DOCK_SAMBA ]; then
	    notice "Configured to mount samba dock ${DOCK_SAMBA}"
	    loadmod smbfs
	    mount -t smbfs "${DOCK_SAMBA}" "${MNT}"
	    if [ $? != 0 ]; then # mount failed
		error "mount failed, remote dock aborted"
	    else
		if ! [ -r "${MNT}/dyne" ]; then
		    error "no dynebolic system found on ${DOCK_SAMBA}"
		    unmount ${MNT}
		else
		    DYNE_SYS_MEDIA="samba"
		    DYNE_SYS_MNT="${MNT}"
		    DYNE_SYS_DEV="${DOCK_REMOTE}"
		    #got_home ${MNT} # have you got a home in it? DEPRECATED
		fi
	    fi
	fi



    else
	error "Can't activate network device: network boot is aborted"
    fi
fi

if [ -z $DYNE_SYS_MEDIA ]; then # no samba was mounted
    
    # call the procedure to select and upgrade detected systems
    # see /lib/dyne/volumes.sh
    choose_volumes

fi

# see /lib/dyne/nest.sh
choose_nest

# dump what we've found into the dyne environmental conf
echo "# dynebolic environment" >> /boot/dynenv
echo "# this file is generated by the Startup script at every boot" >> /boot/dynenv
#echo "# made on `date`" >> /boot/dynenv
echo "# Startup \$Id: rc.S,v 1.20 2005/04/22 08:54:17 jaromil Exp $" >> /boot/dynenv
#echo "# running on `uname -a`" >> /boot/dynenv
echo >> /boot/dynenv
echo "export DYNE_SYS_DEV=${DYNE_SYS_DEV}" >> /boot/dynenv
echo "export DYNE_SYS_MEDIA=${DYNE_SYS_MEDIA}" >> /boot/dynenv
echo "export DYNE_SYS_MNT=${DYNE_SYS_MNT}" >> /boot/dynenv
echo "export DYNE_NEST_VER=${DYNE_NEST_VER}" >> /boot/dynenv
echo "export DYNE_NEST_PATH=${DYNE_NEST_PATH}" >> /boot/dynenv





# TODO:
# scsi
# tftp
# usb sys
# nfs
# a me mi piace la gnutella con lufs :)
# if you feel like, mail dynebolic@dyne.org with the patch




exit 0;


