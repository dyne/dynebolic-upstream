#!/bin/sh --no-zle
#
# LICENSE STUFF (for what is worth on a shell script):
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
#
# this was originally the Bolic1 startup
#
# SEVERAL modification followed, this file is no more the same but we all
# love to remember where it comes, because here everything gets started :^)
#
# this is the first file executed by the init(8) process
#
# it's mission is to recognize the attached storage devices, find the dynebolic
# system and mount it in /usr
#
# it tries if any filesystem contains a /dynebolic.sys file in the root
# in case there is, dynebolic.sys is mounted via loopback device on /usr
# the devices are scanned in order: first harddisks, then cdroms, all IDE
# (HINT: many other storages for the system may be supported, read further)
#
# it exits when the /dynebol.sys is loopback mounted on /usr
# it exits from many points of the file, not only the end ;^)
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
# that's a bash script, as you see it's fairly commented
# now blame me, or read the matrix // jaromil, 25feb04 
#
#
#
#
# "$Id$"


source /lib/libdyne.sh


WMNUM=1
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

CD_NUM=0
mount_cdrom() {
# $1 = device, without partition number (es: hdc)
    DEV=$1
    CD_NUM="`expr $CD_NUM + 1`"
    mkdir "/rem/cd${CD_NUM}"
    
  # even if we can't mount it,
  # we add the device to the automount table
    echo "cd${CD_NUM} -fstype=iso9660,ro :/dev/${DEV}" \
	>> /boot/auto.removable
    
  # the filesystem can be mounted: add it to the list of
  # available storage devices allready from here
    add_volume cd "/rem/cd${CD_NUM}"

    echo -n " .  scanning CD ${DEV} (${CDFS}) ... "
    MNT="/rem/cd${CD_NUM}"
    mount -t "$CDFS" -o ro "/dev/${DEV}" ${MNT} 1>/dev/null 2>/dev/null
    
    if [ $? != 0 ]; then
	echo "can't mount device"
    elif ! [ -r "${MNT}/dynebol.sys" ]; then
	echo "system not found"
	umount ${MNT}
    else
	echo "FOUND"

	if [ -z $DYNE_SYS_DEV ]; then
	    # there was no system found on other storage media
	    # so we use the one on the original dynebolic CD
	    act "mounting dynebolic system from CDROM ${DEV}"
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
		DYNE_SYS_DEV="/dev/${DEV}"
		DYNE_SYS_MNT=${MNT}
		DYNE_SYS_MEDIA="cd"
	    fi
	fi
	
      # check if a nest is used
      # if not, use the home.tgz and var.tgz from this CD
	if [ -z $DYNE_NEST_PATH ]; then
	    # (from the former rc.vfs)
	    notice "initializing virtual RAM filesystem"
	    RAMSIZE=`cat /proc/meminfo |grep MemTotal: |chomp -- 2`
	    SHMSIZE=`expr $RAMSIZE / 1024 / 4`
	    act "RAM detected: `expr $RAMSIZE / 1024` Mb"
	    act "VFS size: $SHMSIZE Mb"
	    echo "tmpfs /dev/shm tmpfs defaults,size=${SHMSIZE}m 0 0" >> /boot/fstab
	    cp /boot/fstab /etc

	    mount /dev/shm

      # creating /var /tmp and /home
	    act "populating /var from CD"
	    tar xfz "${MNT}/var.tgz" -C /dev/shm
	    mount -o bind /dev/shm/var /var
	    
	    act "populating /home from CD"
	    tar xfz "${MNT}/home.tgz" -C /dev/shm
	    mount -o bind /dev/shm/home /home
	    
	    act "building /tmp"
	    mkdir /dev/shm/tmp
	    mount -o bind /dev/shm/tmp /tmp

	fi
    fi	
    
    if [ $DYNE_SYS_DEV ]; then
	# this is the dyne:bolic CD
	# no system is used from it
	# so we can eject this cdrom!
	umount ${MNT}
	eject "/dev/${DEV}"
    else
        # link the goodies in it
	if [ -e "${MNT}/extras" ]; then
	    mount -o bind "${MNT}/extras" /home/extras
	fi
    fi
    
}

XBOX_NUM=0
mount_xbox() {
# $1 = partition, with partition number (es: hda50)
    XBOX_DEV=$1
    
    if ! [ -e "/dev/${XBOX_DEV}" ]; then return; fi
    
    echo -n " .  scanning XBOX HD ${XBOX_DEV} ... "
    XBOX_NUM="`expr $XBOX_NUM + 1`"
    mkdir "/vol/hd${XBOX_NUM}"
    mount -t fatx "/dev/${XBOX_DEV}" "/vol/hd${XBOX_NUM}" 1>/dev/null 2>/dev/null
    
    if [ $? != 0 ]; then
	echo "[!] can't mount partition (not a fatx?)"
	rm -r "/vol/hd${XBOX_NUM}"
	XBOX_NUM="`expr $XBOX_NUM - 1`"
	return
    fi 
    
  # a mountable haddisk partition has been found!
    add_volume hdisk "/vol/hd${XBOX_NUM}"
    
    
  # if the system has been allready mounted you can go on
    if [ $DYNE_SYS_DEV ]; then return; fi
    
    if ! [ -r "/vol/hd${XBOX_NUM}/dynebol.sys" ]; then
	echo "system not found"
    else
	echo "FOUND!"
	
	act "using dynebolic system on ${XBOX_DEV} mounted on /vol/hd${XBOX_NUM}"
	mount -o loop -t squashfs "/vol/hd${XBOX_NUM}/dynebol.sys" /usr
	
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

    echo -n " .  scanning HD ${PART} ... "
    HD_NUM="`expr $HD_NUM + 1`"
    MNT="/vol/hd${HD_NUM}"
    mkdir ${MNT}
    mount "$PART" ${MNT} 1>/dev/null 2>/dev/null
    
    if [ $? != 0 ]; then
      echo "can't mount device"
      rm -r ${MNT}
      HD_NUM="`expr $HD_NUM - 1`"
      continue
    fi
    
    # a mountable harddisk partition has been found!
    add_volume hdisk ${MNT}

    # if the system has been allready mounted you can go on
    if [ $DYNE_SYS_DEV ]; then return; fi
    
    # ok now keep on checking if the system is there
    if ! [ -r "${MNT}/dynebol.sys" ]; then
	echo "system not found"
    else
	echo "FOUND"
	
	act "using dynebolic system on ${PART} mounted on ${MNT}"
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
    fi
    
    sync

  done

}

##########################
### HERE STARTS THE MAIN()
##########################

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
    notice "search dynebolic system on XBOX HARDDISK"
    mount_xbox "hda50"
    mount_xbox "hda51"
    mount_xbox "hda52"
    mount_xbox "hda53"
    mount_xbox "hda55"
else    
    notice "search dynebolic system on IDE HARDDISK devices"
# cycle thru devices
    for DEV in `ls --color=never /proc/ide/hd* -d | chomp -- 3`; do
	
# skip if not an harddisk
	if  [ `cat /proc/ide/$DEV/media` != disk ]; then continue; fi
	
# try to mount it
	mount_harddisk $DEV
	
	sync
	
    done
    
fi



###### CDROM

# CD filesystem is iso9660 unless we have a DVD (on xbox, for example)
if [ ! -z "`uname -a | grep xbox`" ]; then
    echo "[*] searching dynebolic system on XBOX DVD"
    CDFS="udf"
else
    echo "[*] search dynebolic system on IDE CDROM devices"
    CDFS="iso9660"
fi

for DEV in `ls --color=never /proc/ide/hd* -d | chomp -- 3`; do
    
    if  [ `cat /proc/ide/$DEV/media` != cdrom ]; then continue; fi
    
    mount_cdrom $DEV
    
    sync

done


##### FLOPPY DISK
### TODO : configuration file
if [ "`dmesg |grep fd0`" ]; then
    echo "floppy -fstype=auto,sync :/dev/fd0" >> /boot/auto.removable
    add_volume floppy "/rem/floppy"
    sync
fi

##### USB STORAGE
### TODO: configuration file and nest
if [ "`lspci |grep USB`" ]; then
    loadmod sd_mod
    loadmod usb-storage
    loadmod vfat
    sync
    mkdir /rem/usb
    if [ -r /dev/sda1 ]; then # TODO: check more carefully
	notice "USB device found - mounting /dev/sda1 on /rem/usb"
	mount -o sync,rw /dev/sda1 /rem/usb
	act "this is a DEBUG TEST, hope it all went well"
	ls -l /rem/usb
	umount /rem/usb
    fi
    echo "usb -fstype=auto,sync :/dev/sda1" >> /boot/auto.removable
    add_volume usb "/rem/usb"
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
# a me mi piace la gnutella
# mail dynebolic@dyne.org with the patch
# use diff(1) to create a patch with your modifications




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
echo "# running on `uname`" >> /boot/dynenv
echo >> /boot/dynenv
echo "DYNE_SYS_VER=`cat /usr/etc/DYNEBOLIC`" >> /boot/dynenv
echo "DYNE_SYS_DEV=${DYNE_SYS_DEV}" >> /boot/dynenv
echo "DYNE_SYS_MEDIA=${DYNE_SYS_MEDIA}" >> /boot/dynenv
echo "DYNE_SYS_MNT=${DYNE_SYS_MNT}" >> /boot/dynenv
if [ -z $DYNE_NEST_PATH ]; then
    echo "DYNE_INITRD_VER=`cat /etc/DYNEBOLIC`" >> /boot/dynenv
else
    echo "DYNE_NEST_PATH=${DYNE_NEST_PATH}" >> /boot/dynenv
    echo "DYNE_NEST_VER=${DYNE_NEST_VER}" >> /boot/dynenv
fi
exit 1
