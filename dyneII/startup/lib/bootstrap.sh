# dyne:II bootstrap functions
# copyleft 2001 - 2006 Denis "jaromil" Rojo

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


# the following files contain various shell functions
# that are called by this script
source /lib/dyne/services.sh
source /lib/dyne/language.sh
source /lib/dyne/volumes.sh
source /lib/dyne/modules.sh
source /lib/dyne/wmaker.sh
source /lib/dyne/nest.sh
source /lib/dyne/xvga.sh

source /boot/dynenv

# notice we're booting
if ! [ -r /boot/mode ]; then
  echo "booting" > /boot/mode
fi

##########################################




##########################################
## SINGLE USER MODE (ex rc_S)

boot_single_user_mode() {

notice "booting in single user mode"

# launch system logging daemon
/sbin/syslogd

export PATH=/bin:/sbin

touch /var/run/utmp
touch /var/log/wtmp

# create a /tmp directory in ramdisk
mkdir -p    /tmp
chmod a+rwx /tmp
chmod +t    /tmp
####

notice "dyne:bolic hardware device detection"
mount /proc
# deactivate hotplug at boot
echo "0" >> /proc/sys/kernel/hotplug

act "`cat /proc/cpuinfo|grep 'model name'|cut -d: -f2`"
act "`cat /proc/cpuinfo|grep 'flags'|cut -d: -f2`"


notice "initializing device filesystem"

mount -o remount,rw /

mount -t sysfs  sysfs  /sys

mount -t devpts devpts /dev/pts

# mount -o size=8m -t tmpfs tmpfs /dev

# launch the udev daemon
act "launching device filesystem daemon"
/sbin/udevd --daemon

## load the kernel modules available to ramdisk
## this is useful if we want to mount remote network systems
## or any special device which is not statically supported in kernel
# syntax: comma separated list of modules (no extension)
#         or 'autodetect'
# the modules need to be provided in ramdisk, pack them using dynesdk:
# dynesdk -m pcmcia,pcmcia_core,yenta_socket,ide-cs mkinitrd
CFG_MODULES="`get_config modules_ramdisk`"
if [ $CFG_MODULES ]; then
    notice "load kernel modules available to ramdisk"

    act "configured kernel modules: ${CFG_MODULES}"

    for m in `iterate ${CFG_MODULES}`; do

      if [ "$m" = "autodetect" ]; then

	act "modules autodetection invoked"
	for am in `pcimodules`; do
	    loadmod ${am}
	done

      else

	loadmod ${m}

      fi

    done

fi



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
     while [ -z `dmesg | grep '^usb-storage: device scan complete'` ]; do
         echo -n "."
         sleep 1 # wait that the kernel scans before we scan
     done
   fi
  
fi

act "populating device filesystem"
udevstart

#########################################
## scan all volumes by default
scan_hdisk=true
scan_cdrom=true
scan_usb=true

do_scan_storage="`get_config scan_hdisk`"
if ! [ "$do_scan_storage" = "false" ]; then
 notice "scan for fixed storage volumes"
 scan_storage
fi

##

do_scan_removable="`get_config scan_usb`"
if ! [ "$do_scan_removable" = "false" ]; then
  notice "scan for removable storage plugs"
  scan_removable
fi

##

do_scan_cdrom="`get_config scan_cdrom`"
if ! [ "$do_scan_cdrom" = "false" ]; then
  notice "scan for cdrom devices"
  scan_cdrom
fi

##


#### if network boot is configured...
# at this point all modules should be loaded in order to have
# the network card recognized. put needed modules in /boot or in a dock
BOOT_NETWORK="`get_config network_boot`" # "iface ip_address netmask gateway dns" or "dhcp"
if [ $BOOT_NETWORK ]; then

    if [ "`ifconfig -a | grep eth`" ]; then

	notice "Network booting is configured"

        IFACE=`echo $BOOT_NETWORK   | cut -d, -f1`
        IP=`echo $BOOT_NETWORK      | cut -d, -f2`
        if [ "`echo $IP | grep -iE 'pump|dhcp|auto'`" ]; then
          act "autodetect network configuration (DHCP)"
          pump -i ${IFACE}
        else
          act "configuring interface ${IFACE} with ip ${IP}"
          ifconfig ${IFACE} ${IP}
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
            sync
	    mount -t smbfs -o ro,guest,ttl=10000,sock=IPTOS_LOWDELAY,TCP_NODELAY //${DOCK_SAMBA}/dyne.dock /mnt/smbdock
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
                    add_volume samba ${DOCK_SAMBA} smbdock smbfs
		fi
	    fi
	fi



    else
	error "Can't find any network device: network boot is aborted"
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

# create a useful link to the dock
ln -s ${DYNE_SYS_MNT} /lib/dyne/configure/Dyne

}
##########################################







##########################################
## MULTI USER MODE (ex rc_M)

boot_multi_user_mode() {

notice "going into multi user mode"

source /boot/dynenv

######## HOME IS MOUNTER HERE
############ ALL MEDIA MOUNTED, now MOUNT dyne.sys

########################################
## check if a dock was really found
## or volatile mode was choosen
SYSTEM_FOUND="`cat /boot/volumes | grep -E '(sys|sdk)'`"
VOLATILE="`get_config volatile`"

if ! [ $SYSTEM_FOUND ]; then

  # no system found on any harddisk or cdrom
  error "No dyne system has been found on any storage device"
  error "this is a fatal error, dyne:bolic cannot run."
  umount -a
  error "You can safely reboot now, or wait to enter a mantainance shell."
  bootmode=volatile

elif [ $VOLATILE ]; then

  bootmode=volatile

fi

if [ "$bootmode" = "volatile" ]; then
    # stay into the ramdisk shell
    # for the volatile mode activable at boot prompt
    echo
    echo
    echo "VOLATILE MODE :: opening a shell in dyne:bolic ramdisk"
    echo "you are entering a mantainance sector, whatever that means ;)"
    echo
    echo "you are root and your password is luther."
    echo
    echo
    echo
    echo
    # make sure we are in read-write
    mount -o remount,rw /

    ## setup the interactive shell prompt
    rm -f /boot/mode
    echo "volatile" > /boot/mode

    if [ -r /etc/zshrc ]; then rm -f /etc/zshrc; fi
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
fi


########################################





########################################
## DETECT AND MOUNT NEST (or RAM VFS)
# see /lib/dyne/nest.sh
choose_nest
###########




mkdir -p /usr

# check if we have an update
if [ -r ${DYNE_SYS_MNT}/update/VERSION ]; then
  source ${DYNE_SYS_MNT}/update/VERSION

  ask_yesno 10 \
"the Dock on your harddisk contains an update:\n\n
 dyne.sys version ${DYNE_SYS_VER}\n
 initrd.gz version ${DYNE_INITRD_VER}\n
 Do you want to apply it to the current system?"

  if [ $? = 1 ]; then
    src=${DYNE_SYS_MNT}/update
    dst=${DYNE_SYS_MNT}

    notice "updating docked system, please wait while copying files..."
    act "when complete, this computer will be rebooted."
    if [ -r $src/initrd.gz ]; then
      act "updating ramdisk"
      mv $src/initrd.gz $dst/initrd.gz
    fi
    if [ -r $src/linux ]; then
      act "updating kernel"
      mv $src/linux     $dst/linux
    fi
    if [ -r $src/dyne.sys ]; then
      act "updating core binary system"
      mv $src/dyne.sys  $dst/dyne.sys
    fi

    if [ -x $src/modules ]; then
      act "updating modules"
      ls $src/modules
      mv $src/modules/* $dst/modules/
    fi

    # avoid to update next time
    rm $src/VERSION

    notice "system is now rebooting..."
    sync
    umount $DYNE_SYS_MNT
    sleep 3
    reboot
  fi 

fi

if [ -x ${DYNE_SYS_MNT}/SDK/sys/bin ]; then
  # we have an uncompressed dock in the SDK

  notice "Mounting SDK filesystem from dock in ${DYNE_SYS_MNT}"
  mount -o bind,suid ${DYNE_SYS_MNT}/SDK/sys /usr

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
    mount -o loop,ro,suid -t squashfs ${DYNE_SYS_MNT}/dyne.sys /usr

  else

    act "making the /usr writable with unionfs"

    # mount read-only /usr into /mnt/usr
    mkdir -p /mnt/usr
    mount -o loop,ro,suid -t squashfs ${DYNE_SYS_MNT}/dyne.sys /mnt/usr

    if [ $? = 0 ]; then

      # load union filesystem module from inside the squash
      insmod /mnt/usr/lib/modules/`uname -r`/kernel/fs/unionfs/unionfs.ko

      if [ $? = 0 ]; then

        # create directory where to store unionfs changes
        mkdir -p /var/cache/union/usr_rw
        # mount the unionfs layers
        # /var/cache/union/usr_rw <- read/write, stores modifications
        # /mnt/usr <- read only, core system
        mount -t unionfs \
              -o dirs=/var/cache/union/usr_rw=rw:/mnt/usr=ro unionfs /usr
        sync

      else

        error "failed to load unionfs kernel module, reverting /usr to read-only mode"
        mount -o loop,ro,suid -t squashfs ${DYNE_SYS_MNT}/dyne.sys /usr

      fi

    else

      # mount of dyne.sys squashfs failed - fatal :(
      error "fatal error occurred: can't mount dyne.sys filesystem"

    fi

  fi

fi

if ! [ -x /usr/bin ]; then # if we couldn't mount
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
  error "refer to the DOCUMENTATION online"
  error "wiki on lab.dyne.org/DyneBolicFAQ"
  error "may the source be with you :^)"
  echo; echo;

  # no system found on any harddisk or cdrom
  error "No dyne system has been found on any storage device"
  error "this is a fatal error, dyne:bolic cannot run."
  error "You can safely reboot."

  rm -f /boot/mode
  echo "volatile" > /boot/mode
  exit 0;
fi

##########################################
# WE HAVE THE SYSTEM MOUNTED now!

# now the system is mounted expand our PATH
export PATH=/usr/bin:/usr/sbin:$PATH

# link bash to sh
ln -sf /usr/bin/bash /bin/sh

dmesg -n 1

# notice "start multiuser system log monitor"
# killall syslogd
# /usr/sbin/syslogd

# start linker cache
touch /etc/ld.so.conf
append_line /etc/ld.so.conf /usr/lib
append_line /etc/ld.so.conf /usr/X11R6/lib

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

# configure your pcmcia
init_pcmcia

# configure your sound card
init_sound

# configure firewire
init_firewire

# configure network
BOOT_NETWORK="`get_config network_boot`"
if ! [ $BOOT_NETWORK ]; then # avoid reconfiguration
  init_network
fi

# configure language
init_language


#act "repopulating device filesystem"
#udevstart


# notice "mounting static filesystem table"
# if [ -r /etc/fstab.static ]; then
#   # process static fstab rules
#   fstab.static="`cat /etc/fstab.static`"
#   for i in ${(f)fstab.static}; do
# 
#     # skip comments
#     if [ $i[0] = "#" ]; then continue; fi
# 
#     mnt=`echo $i | awk '{ print $2 }'`
# 
#     # append the line to the existent fstab
#     append_line /etc/fstab "$i"
#
#     # mount it
#     mkdir -p ${mnt}
#     mount ${mnt}
#
#   done
#
# fi



# load ACPI modules and launch daemon
activate_acpi

# activate hotplug
echo "/sbin/hotplug" >> /proc/sys/kernel/hotplug

# from services.sh - setup volumes to 77% unmuted
raise_soundcard_volumes


##########################################
## activate all dyne modules
## looks into dyne/modules
## or in dyne/SDK/modules if sdk=true
notice "activating additional dyne modules"
mount_dyne_modules
# see /lib/dyne/modules.sh
## scan all applications present in the running system
notice "scanning installed applications"
source /boot/dynenv.modules
check_apps_present

## scan for bootloaders
for i in `cat /boot/volumes | awk '/^hdisk/ { print $3 }'`; do
  if [ -x ${i}/boot/grub ]; then
    act "grub bootloader found in $i"
    ln -sf ${i}/grub /boot/
  fi
done

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
lspci > /boot/pcilist
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
mode=`cat /boot/mode`
if [ "$mode" = "volatile" ]; then
  exit 0;
fi


notice "going in graphical user mode"



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
## full dyne mode

  source /lib/dyne/zsh/env

  # autodetect the video driver for X
  # and load necessary kernel modules
  # see xvga.sh
  detect_x_driver 

  notice "initializing window manager"
  # generate window manager menu entries
  fluxbox_gen_menu
  wmaker_gen_menu


  # generate window manager volumes entries
  #wmaker_gen_volumes
  rox_gen_volumes
  wmaker_gen_volumes

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


#### FINAL PART
## spawn graphical interface accordingly
## we use xinit to startup X as root,
## which executes the .xinitrc in each user's home
## or we use xdm to startup multiuser login
## which executes the .xsession in each user's home
##
## both .xinitrc and .xsession will execute dyne_startx() in wmaker.sh
## to make your own startup x use the dyne.cfg configuration "startx"

  # cleanup leftover locks (if there was a crash)
  if [ -r /tmp/.X0-lock ]; then
    rm -f /tmp/.X0-lock
  fi
  # setup a bootcheck for fbdev fallback
  touch /tmp/.booting_x
  chmod a+w /tmp/.booting_x
  # we delete it in startx, if X works


  bootstrap_x
  sleep 10
  # X didn't started, let's try with framebuffer
  if [ -r /tmp/.booting_x ]; then
    warning "X graphical environment can't use acceleration on your video card"
    warning "we're going to use normal framebuffer video drivers"
    cp -f /etc/X11/xorg.conf.dist /etc/X11/xorg.conf
    bootstrap_x
    sleep 10
  fi

  # not even framebuffer works! we're left in ASCII mode
  if [ -r /tmp/.booting_x ]; then
    error "X graphical environment doesn't work on your computer, sorry."
    error "you are left with this text only ASCII console."
    rm -f /boot/mode
    echo ascii > /boot/mode
    # startup gpm
    gpm -m /dev/psaux -t ps2 &
  fi

  exit 0


}



