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
# the dyne:bolic rewrite was done by Jaromil
# USB nesting was reenginered by Richard Griffith
#
#
# "$Id$"


source /lib/libdyne.sh


WMNUM=2
WMCFG="/boot/WMState"
add_volume() {
  # $1 = media type (hdisk|floppy|usbkey|cd)
  # $2 = mount point
  case "$1" in
      "hdisk")
	  echo "," >> $WMCFG;
	  echo "{" >> $WMCFG;
	  echo "Name = \"Hd${WMNUM}.HardDisk\";" >>$WMCFG;
	  echo "Lock = yes;" >>$WMCFG;
	  echo "Autolaunch = no;" >>$WMCFG;
	  echo "Command = \"xwc ${2}\";" >>$WMCFG;
	  echo "Position = \"0,${WMNUM}\";" >>$WMCFG;
	  echo "Forced = no;" >>$WMCFG;
	  echo "BuggyApplication = no;" >>$WMCFG;
	  echo "}" >>$WMCFG;
	  ;;
      "floppy")
	  echo "," >>$WMCFG;
	  echo "{" >> $WMCFG;
	  echo "Name = \"Floppy${WMNUM}.FloppyDisk\";" >>$WMCFG
	  echo "Lock = yes;" >>$WMCFG
	  echo "Autolaunch = no;" >>$WMCFG
	  echo "Command = \"xwc ${2}\";" >>$WMCFG
	  echo "Position = \"0,${WMNUM}\";" >>$WMCFG;
	  echo "Forced = no;" >>$WMCFG;
	  echo "BuggyApplication = no;" >>$WMCFG;
	  echo "}" >>$WMCFG;
	  ;;
      "usb")
	  echo "," >>$WMCFG;
	  echo "{" >> $WMCFG;
	  echo "Name = \"Usb${WMNUM}.UsbStorage\";" >>$WMCFG
	  echo "Lock = yes;" >>$WMCFG
	  echo "Autolaunch = no;" >>$WMCFG
	  echo "Command = \"xwc ${2}\";" >>$WMCFG
	  echo "Position = \"0,${WMNUM}\";" >>$WMCFG;
	  echo "Forced = no;" >>$WMCFG;
	  echo "BuggyApplication = no;" >>$WMCFG;
	  echo "}" >>$WMCFG;
	  ;;
      "cd")
	  echo "," >>$WMCFG;
	  echo "{" >> $WMCFG;
	  echo "Name = \"Cd${WMNUM}.CdRom\";" >>$WMCFG
	  echo "Lock = yes;" >>$WMCFG
	  echo "Autolaunch = no;" >>$WMCFG
	  echo "Command = \"xwc ${2}\";" >>$WMCFG
	  echo "Position = \"0,${WMNUM}\";" >>$WMCFG;
	  echo "Forced = no;" >>$WMCFG;
	  echo "BuggyApplication = no;" >>$WMCFG;
	  echo "}" >>$WMCFG;
	  ;;

      *)
	  error "invalid call to dyne_gen_wmaker_dock() in libdyne.sh"
	  return 0
	  ;;
  esac
  act "${1} volume mounted on ${2}"
  WMNUM="`expr $WMNUM + 1`"
}

activate_nest() {
  # we mounted the nest! now link the directories!
  echo " ... OK";

  # rc.nestclean now is here:
  #zap old logs
  if [ -r /mnt/nest/var/log/dynebolic.log ]; then
    rm /mnt/nest/var/log/dynebolic.log
  fi
  # wipe out /tmp
  if [ -x /mnt/nest/tmp ]; then
    rm -rf /mnt/nest/tmp/*
  fi

  if [ ! -e /mnt/nest/home ]; then
	  warning "nest is missing home, skipping"
  else
	  if [ ! -e /home ]; then mkdir /home; fi
	  mount -o bind /mnt/nest/home /home
  fi
  if [ ! -e /mnt/nest/etc ]; then
	  warning "nest is missing etc, skipping"
  else
	  if [ ! -e /etc ]; then mkdir /etc; fi
	  sync
	  cp /etc/mtab /mnt/nest/etc/mtab
	  mount -o bind /mnt/nest/etc /etc
  fi
  if [ ! -e /mnt/nest/var ]; then
	  warning "nest is missing var, skipping"
  else
	  if [ ! -e /var ]; then mkdir /var; fi
	  mount -o bind /mnt/nest/var /var
  fi
  if [ ! -e /mnt/nest/tmp ]; then
	  warning "nest is missing tmp, skipping"
  else
	  if [ ! -e /var ]; then mkdir /tmp; fi
	  mount -o bind /mnt/nest/tmp /tmp
  fi

}

got_home() {
# $1 = path where to take home.tgz and var.tgz
# this check if a home has been found
# if not, use the home.tgz and var.tgz from the given path

    # do we allready have a home? if yes just return
    if [ -r /home/.xinitrc ]; then return; fi

    if [ -r ${1}/dynebol.nst ]; then
	NEST="${1}/dynebol.nst"
	unset ENCRYPT
    elif [ -r ${1}/dynebolE.nst ]; then
	NEST="${1}/dynebolE.nst"
	ENCRYPT="AES128"
    else unset NEST; fi
    
    if [ $NEST ]; then
	echo -n "[?] mount the dyne:bolic nest in ${NEST}"
	getkey 10
	if [ $? = 1 ]; then
	    echo " ... SKIPPED"
	else
	    echo " ... OK"
	    
        # parses the values in a config file, if present
        # this is needed just to know if the nest is encrypted
	# source "`echo ${NEST}|cut -d. -f1`.cfg"
	    
	    notice "activating dyne:bolic nest in ${NEST}"
	    
	    if [ $ENCRYPT ]; then
		act "encrypted with algo $ENCRYPT"
		cat <<EOF




*******************************************************************************
An $ENCRYPT encrypted nest
has been detected in $DYNEBOL_NST
access is password restricted, please supply your passphrase now

EOF
		for i in 1 2 3; do
		    mount -o loop,encryption=$ENCRYPT ${NEST} /mnt/nest
		    case $? in
			0) notice "valid password entered, activating nest!"
			    sleep 1
			    activate_nest
			    break
			    ;;
			32) error "Invalid password"
			    sleep 2
			    continue
			    ;;
			*) error "mount failed with exitcode $?"
			    sleep 2
			    continue
		    esac
		done
		
	    else # nest is not encrypted
		echo -n "[*] mounting nest over loopback device"
		mount -o loop ${NEST} /mnt/nest
		if [ $? != 0 ]; then
		    error "mount failed with exitcode $?"
		    sleep 2
		else
		  activate_nest
		fi
	    fi
	    
	    if [ "`mount | grep /mnt/nest`" ]; then
		act "nest succesfully mounted"
		DYNE_NEST_PATH=${NEST}
	    fi
	fi
	
    else # there isn't a nest, look for standard home and var
	
	if [ ! -r ${1}/home.tgz ]; then return; fi
	if [ ! -r ${1}/var.tgz ]; then return; fi
	
    # (from the former rc.vfs)
	notice "initializing virtual filesystem in memory"
	RAMSIZE=`cat /proc/meminfo |grep MemTotal: |chomp -- 2`
	SHMSIZE=`expr $RAMSIZE / 1024 / 4`
	act "RAM detected: `expr $RAMSIZE / 1024` Mb"
	act "VFS size: $SHMSIZE Mb"
	echo "tmpfs /dev/shm tmpfs defaults,size=${SHMSIZE}m 0 0" >> /boot/fstab
	cp -f /boot/fstab /etc
	mount /dev/shm
	
    # creating /var /tmp and /home
	act "populating /var from CD"
	tar xfz "${1}/var.tgz" -C /dev/shm
	mount -o bind /dev/shm/var /var
	
	act "populating /home from CD"
	tar xfz "${1}/home.tgz" -C /dev/shm
	mount -o bind /dev/shm/home /home
	
	act "building /tmp"
	mkdir /dev/shm/tmp
	mount -o bind /dev/shm/tmp /tmp

	DYNE_NEST_PATH=${1}
    fi

    if [ -r /etc/DYNEBOLIC ]; then
      DYNE_NEST_VER=`cat /etc/DYNEBOLIC`
    fi
}

CD_NUM=0
mount_cdrom() {
# $1 = device, without partition number (es: hdc)
    act "scanning CD ${DEV} (${CDFS})"
    DEV=$1
    CD_NUM="`expr $CD_NUM + 1`"
    MNT="/mnt/dynebolic"
    if [ ! -x ${MNT} ]; then mkdir ${MNT}; fi
   
    mount -t "$CDFS" -o ro "/dev/${DEV}" ${MNT} 1>/dev/null 2>/dev/null

    # can't mount the device, it's likely a void cd reader    
    if [ $? != 0 ]; then
        # if we can't mount it, we add it to the automounted volumes
        echo "cd${CD_NUM} -fstype=iso9660,ro :/dev/${DEV}" \
	     >> /boot/auto.removable
        add_volume cd "/rem/cd${CD_NUM}" 
        return
    fi

    # have you got brand new home in this cd?
    got_home ${MNT}
    # if there is a dyne subdirectory, then use that
    if [ -x "${MNT}/dyne" ]; then MNT="${MNT}/dyne"; fi
    got_home ${MNT}    

    ###### now the SYSTEM
    if ! [ -r "${MNT}/dynebol.sys" ]; then
	act "the dynebolic system is not here"
	umount "/mnt/dynebolic"
	# then we add it anyway to the automounted volumes
        echo "cd${CD_NUM} -fstype=iso9660,ro :/dev/${DEV}" \
	     >> /boot/auto.removable
        add_volume cd "/rem/cd${CD_NUM}" 
	return
    elif [ ! -x /usr/bin/dynesplash ]; then
	# there was no system found so far on other storage media
	# so we use the one on this CD, remounting on /mnt/dynebolic
	notice "FOUND dynebolic system on CD ${DEV}"

	mount -o loop -t squashfs "${MNT}/dynebol.sys" /usr
	
	if [ $? != 0 ]; then
	    echo
	    error "a problem occurred while mounting the dynebol.sys"
	    error "it looks like your CD is corrupted!"
	    echo
	    error "burn it more carefully: less speed and don't do ANYTHING else"
	    error "with your computer while burning. refer to the USER UPDATED FAQ"
	    error "on the wiki pages on lab.dyne.org/DyneBolicFAQ for some tips"
	    error "may the source be with you :^)"
	    echo; echo;
	    sleep 10
	else
	    # the system has been correctly mounted
	    DYNE_SYS_DEV="/dev/${DEV}"
	    DYNE_SYS_MNT=/mnt/dynebolic
	    DYNE_SYS_MEDIA="cd"
            # bring home the goodies in the CD
	    if [ -e "${DYNE_SYS_MNT}/extras" ]; then
		if [ ! -e /home/extras ]; then 
		  ln -s "${DYNE_SYS_MNT}/extras" /home/extras
		fi
	    fi	
	fi
    else
	# this is a dynebolic CD, but a system
	# is allready mounted from another media
	# so we can eject this cdrom and put the volume in automount
        notice "system is found on a storage device, CD is free now"
	umount "/mnt/dynebolic"
	eject "/dev/${DEV}"
        echo "cd${CD_NUM} -fstype=iso9660,ro :/dev/${DEV}" \
	     >> /boot/auto.removable
        add_volume cd "/rem/cd${CD_NUM}" 
    fi
}

XBOX_NUM=0
mount_xbox() {
# $1 = partition, with partition number (es: hda50)
    XBOX_DEV=$1
    
    if ! [ -e "/dev/${XBOX_DEV}" ]; then return; fi
    
    act "scanning XBOX HD ${XBOX_DEV}"
    XBOX_NUM="`expr $XBOX_NUM + 1`"
    MNT="/vol/hd${XBOX_NUM}"
    mkdir ${MNT}
    mount -t fatx "/dev/${XBOX_DEV}" ${MNT} 1>/dev/null 2>/dev/null
    
    if [ $? != 0 ]; then
	echo "[!] can't mount partition (not a fatx?)"
	rm -r ${MNT}
	XBOX_NUM="`expr $XBOX_NUM - 1`"
	return
    fi 
    
  # a mountable haddisk partition has been found!
    add_volume hdisk ${MNT}
    

    got_home ${MNT}    
    # if there is a dyne subdirectory, then enter that
    if [ -x "${MNT}/dyne" ]; then MNT="${MNT}/dyne"; fi
    got_home ${MNT}
    

   # if the system has been allready mounted you can go on
    
    if ! [ -r "${MNT}/dynebol.sys" ]; then
	act "the dynebolic system is not here"
	return
    elif [ ! -x /usr/bin/dynesplash ]; then
	notice "FOUND dynebolic system on partition mounted on /vol/hd${XBOX_NUM}"
	
	mount -o loop -t squashfs "${MNT}/dynebol.sys" /usr
	
	if [ $? != 0 ]; then
	    echo
	    error "a problem occurred while mounting the dynebol.sys"
	    error "dynebolic found a corrupted dynebol.sys on ${XBOX_DEV}"
	    error "copy it again from a working dynebolic CD into the root of"
	    error "one of your partitions"
	    echo; echo;
	    sleep 10
	    continue
	else
	  # system successfully mounted
	    DYNE_SYS_DEV="/dev/${DEV}"
	    DYNE_SYS_MEDIA="hd"
	    DYNE_SYS_MNT=${MNT}
	fi
    fi    
} 

HD_NUM=0
mount_harddisk() {
# $1 = device, without partition number (es: hda)
  DEV=$1

# load the filesystem kernel modules needed  
  TESTFS=`fdisk -l /dev/${DEV}`
  if [ "`echo $TESTFS|grep -i DOS`" ]; then
      insmod /boot/msdos.o
  fi
  if [ "`echo $TESTFS|grep -i FAT`" ]; then
      insmod /boot/fat.o
      insmod /boot/vfat.o
  fi
  if [ "`echo $TESTFS|grep -i NTFS`" ]; then
      insmod /boot/ntfs.o
  fi
  if [ "`echo $TESTFS|grep -i BSD`" ]; then
      insmod /boot/ufs.o
  fi
  if [ "`echo $TESTFS|grep -i BEOS`" ]; then
      insmod /boot/bfs.o
  fi
  
  # cycle thru partitions
  for PART in `fdisk -l /dev/${DEV} \
               | grep -iE 'Linux|NTFS|FAT|BSD|BEOS' \
               | grep -i -v swap \
               | cut -d' ' -f1`; do

    act "scanning HD partition ${PART}"
    HD_NUM="`expr $HD_NUM + 1`"
    MNT="/vol/hd${HD_NUM}"
    mkdir ${MNT}
    mount "$PART" ${MNT} 1>/dev/null 2>/dev/null
    
    if [ $? != 0 ]; then
	error "can't mount device"
	rm -r ${MNT}
	HD_NUM="`expr $HD_NUM - 1`"
	continue
    fi
    
    # a mountable harddisk partition has been found!
    add_volume hdisk ${MNT}

    # have you got a home there?
    got_home ${MNT}
    # if there is a dyne development subdirectory, then use that
    if [ -x "${MNT}/dyne/sdk/cdrom/dyne" ]; then
        MNT="${MNT}/dyne/sdk/cdrom/dyne"
	# try also inside the /dyne directory found
	got_home ${MNT}
    # or maybe a simple dyne/ subdir, then take that
    elif [ -x "${MNT}/dyne" ]; then
        MNT="${MNT}/dyne"
	# try also inside the /dyne directory found
	got_home ${MNT}
    fi

    # if the system has been allready mounted you can go on
    if [ -x /usr/bin/dynesplash ]; then continue; fi

    # if the system is not here we are done with this partition
    if ! [ -r "${MNT}/dynebol.sys" ]; then
	act "the dynebolic system is not here"
	continue
    fi
    
    notice "FOUND dynebolic system on partition mounted on ${MNT}"
    
    mount -o loop -t squashfs "${MNT}/dynebol.sys" /usr
    
    if [ $? != 0 ]; then
	echo
	error "a problem occurred while mounting the dynebol.sys"
	error "dynebolic found a corrupted dynebol.sys on ${PART}"
	error "copy it again from a working dynebolic CD"
	echo; echo;
	sleep 10
	continue
    else
	# system succesfully mounted
	DYNE_SYS_DEV=${PART}
	DYNE_SYS_MEDIA="hd"
	DYNE_SYS_MNT=${MNT}
    fi
    
    sync

  done

}

USB_NUM=0
add_usbvolume() {
  # $1 = dev to add

  USB_NUM="`expr $USB_NUM + 1`"

  # make first a 'usb' so taschino can find a usb key
  if [ $USB_NUM == 1 ]; then
    USBNAME="usb"
  else
    USBNAME="usb${USB_NUM}"
  fi

  echo "${USBNAME} -fstype=auto,sync :${1}"  >> /boot/auto.removable
  add_volume usb "/rem/${USBNAME}"
  sync
}

# module loading wrapper for boot, supress messages, deal with buggy hardware
loadbootmod() {
    # in interactive mode we ask 
    if [ "`grep -i interactive /proc/cmdline`" ]; then 
 	echo -n "[?] do you want to load kernel module $1 " | tee -a $LOG
	getkey 10
	if [ $? = 1 ]; then
	    echo " ... SKIPPED" | tee -a $LOG
	    return
	else
	    echo " ... LOADED" | tee -a $LOG
	fi
    fi 
    # finally we do it
    insmod $1 1>>$LOG 2>>$LOG
    if [ $? = 0 ]; then
        act "loaded kernel module $1"
    else
        # no error output to console
	# "i panni sporchi si lavano in famiglia"
        echo "[!] ERROR loading kernel module $1" >> $LOG
    fi
}


##########################
### HERE STARTS THE MAIN()
##########################

# should we even be running?
if [ -r /home/.xinitrc ]; then exit 1; fi

if [ -z $PATH ]; then
    export PATH=/bin:/sbin
fi
 
notice "dyne:bolic hardware device detection"
cp -f /boot/fstab /etc
mount proc

act "`cat /proc/cpuinfo|grep 'model name'|cut -d: -f2`"
act "`cat /proc/cpuinfo|grep 'flags'|cut -d: -f2`"

notice "starting device filesystem daemon"
/sbin/devfsd /dev

sync

notice "load loopback device kernel module"
echo -n " .  " 
if [ -z "`uname -a | grep xbox`" ]; then
  insmod /boot/loop-aes.o \
  max_loop=128 lo_prealloc=100,1,500,6,200 lo_nice=-10
else
  insmod /boot/loop-aes-xbox.o \
  max_loop=128 lo_prealloc=100,1,1000,6,200 lo_nice=-10
fi


###### HARDDISK

# we try out xbox
if ! [ -z "`uname -a | grep xbox`" ]; then
    notice "scan xbox harddisk"
    mount_xbox "hda50"
    mount_xbox "hda51"
    mount_xbox "hda52"
    mount_xbox "hda53"
    mount_xbox "hda55"
else    
    notice "scan ide harddisk"
# cycle thru devices
    for DEV in `ls --color=never /proc/ide/hd* -d | cut -d/ -f4`; do
	
# skip if not an harddisk
	if  [ `cat /proc/ide/$DEV/media` != disk ]; then continue; fi
	
# try to mount it
	mount_harddisk $DEV
	
	sync
	
    done
    
fi



##### USB STORAGE
if [ "`cat /proc/pci | grep USB`" ]; then
  notice "scan usb storage"
  # load usb hardware layer, only one of the next 4 should succeed
  loadbootmod /boot/ehci-hcd.o
  loadbootmod /boot/usb-ohci.o
  loadbootmod /boot/usb-uhci.o
  loadbootmod /boot/uhci.o
  
  loadbootmod /boot/sd_mod.o
  loadbootmod /boot/usb-storage.o
  loadbootmod /boot/fat.o
  loadbootmod /boot/vfat.o
  sync
  sleep 4
  mount -t usbdevfs usbdevfs /proc/bus/usb
  sync

  USBUSED="N"
  foreach DEV in /dev/sd?1 ;

    if [ -r $DEV ]; then # TODO: check more carefully, in proc?
	notice "USB/SCSI device found on $DEV"
	if [ $USBUSED == "N" ]; then
 	  if [ ! -x /vol/usb ]; then mkdir /vol/usb; fi
	  mount -o sync,rw $DEV /vol/usb
          if [ $? != 0 ]; then
	    error "can't mount device"
	    rm -r /vol/usb
          else
	    got_home /vol/usb
	    if [ "${DYNE_NEST_PATH[0,7]}" == "/vol/usb" ]; then
	      USBUSED="Y"
	    else
              umount /vol/usb
              sync
              add_usbvolume $DEV
            fi
	  fi
	else
	  add_usbvolume $DEV
	fi
    fi

  end
  # nothing found, add one in case usbkey is plugged in later
  if [ $USBUSED == "N" ]; then
    if [ $USB_NUM == 0 ]; then
      add_usbvolume /dev/sda1
    fi
  fi
fi

###### CDROM

# CD filesystem is iso9660 unless we have a DVD (on xbox, for example)
if [ "`uname -a | grep xbox`" ]; then
    notice "scan xbox dvd"
    CDFS="udf"
else
    notice "scan ide cdrom"
    CDFS="iso9660"
fi
for DEV in `ls --color=never /proc/ide/hd* -d | cut -d/ -f4`; do
    
    if  [ `cat /proc/ide/$DEV/media` != cdrom ]; then continue; fi
    
    mount_cdrom $DEV
    
    sync

done


##### FLOPPY DISK
if [ "`dmesg |grep ' fd0 '`" ]; then
## you can put a 'dynebol.sh' file inside your floppy disk
## then uncomment this part, and it will be executed at startup
#    notice "scan floppy disk"
#    if [ ! -e /vol/floppy ]; then mkdir /vol/floppy; fi
#    mount /dev/fd0 /vol/floppy
#    sync
#    if [ $? == 0 ]; then
#      if [ -e /vol/floppy/dynebol.sh ]; then
#	zsh -e /vol/floppy/dynebol.sh
#      fi
#    ### TODO : configuration file
#      umount /vol/floppy
#      sync
#    fi
    echo "floppy -fstype=auto,sync :/dev/fd0" >> /boot/auto.removable
    add_volume floppy "/rem/floppy"
    sync
fi

# TODO:
# fetch the system from many other places
# scsi
# tftp
# usb
# nfs
# http,ftp
# rsync
# a me mi piace la gnutella con lufs :)
# mail dynebolic@dyne.org with the patch
# use diff(1) to create a patch with your modifications
# or ask the mailinglist for cvs access
# but let's get to know each other first ;)



if [ -z `mount | grep -i "type squashfs"` ]; then
    echo
    echo "[!] dyne:bolic couldn't find the dynebol.sys file on any device"
    echo "[!] maybe you are running on a system that's not supported yet?"
    echo "[!] arg, this is a fatal error :("
    echo "[!] means: it does'nt works on yours(tm)"
    echo "[!] try to ask for help on dynebolic@dyne.org"
    echo "[!] detailing your system configuration and settings."
    echo
    echo "[!] SCSI storage devices don't work, we need your help to support"
    echo "[!] it is useful if you send informations for the command 'dmesg'"
    echo "[!] from this console you have here."
    echo "[!] this is a fatal error, you are left alone."
    echo
fi

# dump what we've found into the dyne environmental conf
echo "# dynebolic environment" > /boot/dynenv
echo "# this file is generated by the Startup script at every boot" >> /boot/dynenv
echo "# made on `date`" >> /boot/dynenv
echo "# Startup \$Id$" >> /boot/dynenv
echo "# running on `uname -a`" >> /boot/dynenv
echo >> /boot/dynenv
echo "DYNE_SYS_VER=`cat /usr/etc/DYNEBOLIC`" >> /boot/dynenv
echo "DYNE_SYS_DEV=${DYNE_SYS_DEV}" >> /boot/dynenv
echo "DYNE_SYS_MEDIA=${DYNE_SYS_MEDIA}" >> /boot/dynenv
echo "DYNE_SYS_MNT=${DYNE_SYS_MNT}" >> /boot/dynenv
echo "DYNE_NEST_VER=${DYNE_NEST_VER}" >> /boot/dynenv
echo "DYNE_NEST_PATH=${DYNE_NEST_PATH}" >> /boot/dynenv

exit 1

