# dyne:II bootstrap functions
# copyleft 2001 - 2005 Denis "jaromil" Rojo

# this is the third rewrite of dyne:bolic bootstrap process
# done in 2005, after having studied AWK in India

# it contains single- and multi- user mode boot steps
# x startup, reboot and kill
# called by /etc/rc.? scripts which are triggered by /etc/inittab

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




##########################################
# generic checks and includes
source /lib/dyne/utils.sh

if [ -z $INIT_VERSION ]; then
  error "Bootstrap is part of dyne system startup sequence"
  error "and should be only run by the init(1) process"
  exit -1
fi

source /lib/dyne/services.sh
source /lib/dyne/volumes.sh
source /lib/dyne/modules.sh
source /lib/dyne/wmaker.sh
source /lib/dyne/nest.sh

source /boot/dynenv

##########################################







##########################################
## SINGLE USER MODE (ex rc_S)

boot_single_user_mode() {

# launch system logging daemon
/sbin/syslogd

export PATH=/bin:/sbin

echo volatile > /boot/mode
touch /var/run/utmp
touch /var/log/wtmp

# create a /tmp directory in ramdisk
mkdir -p    /tmp
chmod a+rwx /tmp
chmod +t    /tmp
####

notice "dyne:bolic hardware device detection"
mount /proc
act "`cat /proc/cpuinfo|grep 'model name'|cut -d: -f2`"
act "`cat /proc/cpuinfo|grep 'flags'|cut -d: -f2`"

mount /dev/pts
mount /sys

# check if an usb controller is present
if [ "`dmesg | grep 'USB hub found'`" ]; then

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

notice "scan for fixed storage volumes"
scan_storage

##

notice "scan for removable storage plugs"
scan_removable

##

notice "scan for cdrom devices"
scan_cdrom

##

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
	    udhcpc

	else

#	    IFACE=`echo $BOOT_NETWORK   |awk '{print $1}'`
#	    IP=`echo $BOOT_NETWORK      |awk '{print $2}'`
#	    NETMASK=`echo $BOOT_NETWORK |awk '{print $3}'`
#	    GW=`echo $BOOT_NETWORK      |awk '{print $4}'`
#	    DNS=`echo $BOOT_NETWORK     |awk '{print $5}'`
	    IFACE=`echo $BOOT_NETWORK   | cut -d, -f1`
	    IP=`echo $BOOT_NETWORK      | cut -d, -f2`
	    ifconfig ${IFACE} ${IP}
#	    route add default gw ${GW}
#	    echo "nameserver $DNS" > /etc/resolv.conf

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


	DOCK_SAMBA=`get_config dock_mount_samba` # network_address (public access)
	if [ $DOCK_SAMBA ]; then
	    notice "Configured to mount samba dock from ${DOCK_SAMBA}"
	    mkdir -p /mnt/smbdock
	    loadmod smbfs
	    mount -t smbfs -o guest //${DOCK_SAMBA}/dyne.dock /mnt/smbdock >/dev/null
	    if [ $? != 0 ]; then # mount failed
		error "mount failed, remote dock aborted"
	    else
		if ! [ -r "/mnt/smbdock/dyne.sys" ]; then
		    error "no dyne system found on ${DOCK_SAMBA}"
		    umount /mnt/smbdock
		else
		    DYNE_SYS_MEDIA=samba
		    DYNE_SYS_MNT=/mnt/smbdock
		    DYNE_SYS_DEV=${DOCK_SAMBA}
		fi
	    fi
	fi



    else
	error "Can't activate network device: network boot is aborted"
    fi
fi

#### if /usr is not already mounted then let's go looking for a system
#### this control lets have dyne:bolic run from a partition

if ! [ $DYNE_SYS_MEDIA ]; then

  if ! [ -x /usr/bin/dynesplash ]; then
    

  ##### NOW HERE THE SYSTEM SELECTION

    # call the procedure to select and upgrade detected systems
    choose_volumes
    # see /lib/dyne/volumes.sh

  else

    DYNE_SYS_DEV=`get_config root`
    DYNE_SYS_MNT=/
    DYNE_SYS_MEDIA=pre_mounted

  fi

fi


# dump what we've found into the dyne environmental conf
append_line /boot/dynenv "# Dyne environment"
append_line /boot/dynenv "# booted on `date`"
append_line /boot/dynenv "# this file is generated by the Startup script at every boot"
append_line /boot/dynenv "export DYNE_SYS_DEV=${DYNE_SYS_DEV}"
append_line /boot/dynenv "export DYNE_SYS_MEDIA=${DYNE_SYS_MEDIA}"
append_line /boot/dynenv "export DYNE_SYS_MNT=${DYNE_SYS_MNT}"

}
##########################################







##########################################
## MULTI USER MODE (ex rc_M)

boot_multi_user_mode() {


######## HOME IS MOUNTER HERE
############ ALL MEDIA MOUNTED, now MOUNT dyne.sys
##### UNLESS VOLATILE MODE :
VOLATILE="`get_config volatile`"
if [ $VOLATILE ]; then
    # stay into the ramdisk shell
    # for the volatile mode activable at boot prompt
    notice "VOLATILE MODE :: opening a shell in dyne:bolic ramdisk"
    act "you are entering a mantainance sector, whatever that means ;)"

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
    echo "vi - unix text editor"
    echo "insmod - see modules in /boot/modules"
    echo "ifconfig and udhcp - configure network"
    echo "ncftpget - FTP download tool"
    echo "rsync - incremental update from network"
    echo "grep, sed and awk - wild scripting"
    echo "smbmount - samba filesystem"
    echo "happy hacking ;)"
EOF
    
    exit 0
else
    rm -f /boot/mode
    echo ascii > /boot/mode
fi



# if the system has been allready mounted you can go on
if [ "$DYNE_SYS_MEDIA" = "pre_mounted" ]; then
    notice "dyne system on ${DYNE_SYS_DEV} mounted in ${DYNE_SYS_MNT}"
else

    if [ -x ${DYNE_SYS_MNT}/SDK/sys/bin/dynesplash ]; then
        # we have an uncompressed dock in the SDK

	notice "Mounting SDK filesystem from dock in ${DYNE_SYS_MNT}"
	mount -o bind ${DYNE_SYS_MNT}/SDK/sys /usr


    elif [ "$DYNE_SYS_MEDIA" = "samba" ]; then
        # we are mounting the system over the network

        notice "Mounting dock over samba network from ${DYNE_SYS_DEV}"
        mount -o loop,ro,suid -t squashfs ${DYNE_SYS_MNT}/dyne.sys /usr



    elif [ -r ${DYNE_SYS_MNT}/dyne.sys ]; then
        # we have a compressed dock

        notice "Mounting dock in ${DYNE_SYS_MNT}"
        UNIONFS="`get_config unionfs`"
        if [ "$UNIONFS" = "false" ]; then 

           # just mount the /usr as read-only

           mkdir -p /usr
           mount -o loop,ro,suid -t squashfs ${DYNE_SYS_MNT}/dyne.sys /usr

	else

	   act "making the /usr writable with unionfs"
           mkdir -p /mnt/usr
	   mount -o loop,ro,suid -t squashfs ${DYNE_SYS_MNT}/dyne.sys /mnt/usr
	   # load union filesystem module from inside the squash
	   insmod /mnt/usr/lib/modules/`uname -r`/kernel/fs/unionfs.ko
           # mount read-only /usr into /mnt/usr
	   mount -t unionfs -o dirs=/mnt/usr=ro unionfs /usr
	   # writable union will be mounted later on...
	   UNION_USR_RW=/var/cache/union/usr_rw

        fi

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
	exit 0;
    fi
fi

##########################################
# WE HAVE THE SYSTEM MOUNTED now!

# now the system is mounted expand our PATH
export PATH=/usr/bin:/usr/sbin:$PATH

dmesg -n 1

# notice "start multiuser system log monitor"
# killall syslogd
# /usr/sbin/syslogd

notice "scan pci devices"
lspci > /boot/pcilist

# reset linker cache
append_line /etc/ld.so.conf /usr/lib

# detect and mount nest
choose_nest
# see /lib/dyne/nest.sh


act "network loopback device"
ifconfig lo 127.0.0.1


# detect and mount swap partitions
for gh in `fdisk -l | grep -iE "linux.*swap*" | awk '{print $1}'`; do
    act "activating swap partition $gh"
    append_line /etc/fstab "$gh\tswap\t\tswap\tsw\t\t0\t0"
    swapon $gh
done


# here we were detecting xbox for proper module loading
# if [ ! -z "`uname -a | grep xbox`" ]; then

    
# load necessary kernel modules
init_modules

# here we were configuring the videocard for X
# this is now done in the Xorg module
#/etc/init.d/rc.vga


# configure your sound card
init_sound

# configure firewire
init_firewire

# configure network
BOOT_NETWORK="`get_config network_boot`"
if ! [ $BOOT_NETWORK ]; then # avoid reconfiguration
  init_network
fi

##########################################
## activate all dyne modules
## looks into dyne/modules
## or in dyne/SDK/modules if sdk=true
notice "activating additional dyne modules"
mount_dyne_modules
# see /lib/dyne/modules.sh

## scan all applications present in the running system
notice "scanning all installed applications"
check_apps_present



if [ ${UNION_USR_RW} ]; then
  notice "making /usr writable with unionfs"
  # create directory where to store unionfs changes
  mkdir -p /var/cache/union/usr_rw
  # assign /usr writable union to /var/cache/union/usr_rw
  /usr/sbin/unionctl /usr --add --before /mnt/usr \
                     --mode rw /var/cache/union/usr_rw
fi




##########################################
## starting daemons here

notice "launching device filesystem daemon"
/sbin/udevd --daemon

notice "launching power management daemon"
/usr/sbin/acpid

notice "launching common unix printer daemon"
/usr/sbin/cupsd &




# execute rc.local if present
# you can create rc.local in the /etc directory
# and put there the commands to be executed here
# you can also put it in a floppy a:\dyne.sh
# and then uncomment the proper lines in /etc/rc.S
if [ -e /etc/rc.local ]; then
  source /etc/rc.local
fi

notice "boot sequence completed on `date`"
logger -p syslog.info   "kernel:`uname -a`"
logger -p syslog.info   "CPU:`cat /proc/cpuinfo|grep 'model name'|cut -d: -f2`"
logger -p syslog.info   "flags:`cat /proc/cpuinfo|grep 'flags'|cut -d: -f2`"
logger -p syslog.notice "=== devices detected on pci bus:"
lspci | logger -p syslog.info
logger -p syslog.notice "=== kernel modules loaded:"
lsmod | logger -p syslog.info
logger -p syslog.notice "=== mounted filesystems:"
mount | logger -p syslog.info

sync


}

##############################################




##############################################
## GRAPHICAL USER MODE

boot_graphical_user_mode() {

# skip if we're in volatile mode
if [ `cat /boot/mode` = volatile ]; then exit 0; fi



#################################
######## ASCII MODE
ASCII="`get_config ascii`"
if [ $ASCII ]; then
    rm -f /boot/mode
    echo ascii > /boot/mode
    notice "ASCII mode entered"

# startup gpm
    gpm -m /dev/psaux -t ps2 &

## setup the interactive shell prompt
    if [ -r /etc/zshrc ]; then rm /etc/zshrc; fi
    cat > /etc/zshrc <<EOF
# ascii mode
cd
echo "you are running `uname -mnrsp`"
echo "uptime: `/usr/bin/uptime`"
echo
fortune -s
echo
EOF
    exit 0;
else

    rm -f /boot/mode
    echo dyne > /boot/mode

fi
#################################



#################################
#if [ -x /opt/Xorg/bin/X ]; then
### we have Xorg

  ## full dyne mode

  source /lib/dyne/zsh/env

  # generate window manager menu entries
  fluxbox_gen_menu

  # generate window manager volumes entries
  #wmaker_gen_volumes
  rox_gen_volumes


  ## setup the interactive shell prompt for X
  if [ -r /etc/zshrc ]; then rm /etc/zshrc; fi
  cat > /etc/zshrc <<EOF
# dyne mode
cd
echo "you are running `uname -mnrsp`"
echo "uptime: `/usr/bin/uptime`"
echo
fortune -s
echo
EOF

  if [ -z $DYNE_NEST_PATH ]; then
    # start X
    XREMOTE="`get_config x_remote`"
    if [ $XREMOTE ]; then
      su luther -c X -indirect -query ${XREMOTE}
    else
      su luther -c xinit &
    fi
  else
    Login.app &
  fi

  exit 0


#fi

}



