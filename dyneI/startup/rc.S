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






eject_cdrom() {
# recognize the dynebolic CD and eject it
    for DEV in `ls --color=never /proc/ide/hd* -d | cut -d / -f 4`; do
	
	if  [ `cat /proc/ide/${DEV}/media` != cdrom ]; then continue; fi
	
	mount -o ro "/dev/${DEV}" /tmp 1>/dev/null 2>/dev/null
	if [ $? != 0 ]; then continue; fi

	if [ -r /tmp/dynebol.sys -o -r dynebol.ico ]; then
	    umount /tmp
	    sync
	    eject "/dev/${DEV}"
	else
	    umount /tmp
	fi
	    
    done
}

# all the following mount_* functions try to mount the system
# if it works, they exit 1 out of this shell script
# (if the script reaches the very end, there was no /dynebol.sys found anywhere)

mount_cdrom_system() {
# $1 = device, without partition number (es: hdc)
  DEV=$1
  echo -n " .  scanning CDR ${DEV} with ${CDFS} ... "
  mount -t "$CDFS" -o ro "/dev/${DEV}" /mnt/dynebolic 1>/dev/null 2>/dev/null

  if [ $? != 0 ]; then
    echo "can't mount device"
    continue
  fi

  if ! [ -r /mnt/dynebolic/dynebol.sys ]; then
      echo "system not found"
      umount /mnt/dynebolic
      continue
  fi

  echo "FOUND"

  echo -n " .  mounting dynebolic system from CDROM ${DEV}"
  mount -o loop -t squashfs /mnt/dynebolic/dynebol.sys /usr
  
  if [ $? != 0 ]; then
    echo
    echo "[!] a problem occurred while mounting the dynebol.sys"
    echo "[!] it looks like your CD is corrupted!"
    echo "[!]"
    echo "[!] burn it more carefully: less speed and don't do ANYTHING else"
    echo "[!] with your computer while burning. refer to the USER UPDATED FAQ"
    echo "[!] on the wiki pages on lab.dyne.org/DyneBolicFAQ for some tips"
    echo "[!] may the source be with you :^)"
    echo; echo;
    sleep 10
    umount /mnt/dynebolic
    return
  fi

  sync

  echo "${DEV}" > /boot/dynecd

  exit 1 # SUCCESS

}

mount_xbox_system() {
# $1 = partition, with partition number (es: hda50)
  XBOX_DEV=$1

  if ! [ -e "/dev/${XBOX_DEV}" ]; then return; fi
  
  echo -n " .  scanning XBOX harddisk partition ${XBOX_DEV} ... "
  mount -t fatx "/dev/${XBOX_DEV}" /mnt/dynebolic 

  if [ $? != 0 ]; then
    echo "[!] can't mount partition (not a fatx?)"
    sync
    return
  fi 

  if ! [ -r /mnt/dynebolic/dynebol.sys ]; then
    echo "system not found"
    umount /mnt/dynebolic
    sync
    return
  fi
    
  echo "FOUND!"
  
  echo -n " .  using dynebolic system on XBOX partition ${XBOX_DEV}"
  mount -o loop -t squashfs /mnt/dynebolic/dynebol.sys /usr

  if [ $? != 0 ]; then
    echo
    echo "[!] a problem occurred while mounting the dynebol.sys"
    echo "[!] dynebolic found a corrupted dynebol.sys on your partition"
    echo "[!] copy it again from a working dynebolic CD into the root of"
    echo "[!] one of your partitions"
    echo; echo;
    sleep 10
    umount /mnt/dynebolic
    sync
    return
  fi

  sync

  exit 1 # SUCCESS

} 

mount_harddisk_system() {
# $1 = device, without partition number (es: hda)
  DEV=$1

  PART_NUM=0
       
  # cycle thru partitions
  for PART in `fdisk -l /dev/${DEV} \
               | grep -iE 'Linux|NTFS|FAT|BSD|BEOS' \
               | grep -i -v swap \
               | cut -d' ' -f1`; do

    PART_NUM="`expr $PART_NUM + 1`";
    echo -n " .  scanning partition ${PART_NUM} of ${DEV} ... "
    mount "$PART" /mnt/dynebolic 1>/dev/null 2>/dev/null
    
    if [ $? != 0 ]; then
      echo "can't mount device"
      continue
    fi
        
    if ! [ -r /mnt/dynebolic/dynebol.sys ]; then
      echo "system not found"
      umount /mnt/dynebolic
      continue
    fi
	
    echo "FOUND"
      
    echo -n " .  using dynebolic system on HARDDISK ${PART}"
    mount -o loop -t squashfs /mnt/dynebolic/dynebol.sys /usr
    
    if [ $? != 0 ]; then
      echo
      echo "[!] a problem occurred while mounting the dynebol.sys"
      echo "[!] dynebolic found a corrupted dynebol.sys on your partition"
      echo "[!] copy it again from a working dynebolic CD"
      echo; echo;
      sleep 3
      umount /mnt/dynebolic
      continue
    fi

    sync

    exit 1 # SUCCESS

  done # will never loop from here

}



##########################
### HERE STARTS THE MAIN()
##########################

if [ -z $PATH ]; then
    export PATH=/bin:/sbin
fi
 
cp -f /usr/share/dynebolic/templates/fstab.dist /etc/fstab

echo "[*] dyne:bolic hardware device detection"
mount /proc

echo -n " .  running on: "
cat /proc/cpuinfo|grep 'model name'|cut -d: -f2
echo -n " .  cpu flags: "
cat /proc/cpuinfo|grep 'flags'|cut -d: -f2

echo "[*] starting devfs daemon"
/sbin/devfsd /dev

sync

echo "[*] load loopback device kernel module"
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
    echo "[*] search dynebolic system on XBOX HADDISK"
    mount_xbox_system "hda50"
    mount_xbox_system "hda51"
    mount_xbox_system "hda52"
    mount_xbox_system "hda53"
    mount_xbox_system "hda55"
else    
    echo "[*] search dynebolic system on IDE HARDDISK devices"

# mount the filesystem kernel modules needed
    if [ "`fdisk -l | grep -i DOS`" ]; then
	insmod /boot/msdos.o
    fi
    if [ "`fdisk -l | grep -i FAT`" ]; then
	insmod /boot/fat.o
	insmod /boot/vfat.o
    fi
    if [ "`fdisk -l | grep -i NTFS`" ]; then
	insmod /boot/ntfs.o
    fi
    if [ "`fdisk -l | grep -i BSD`" ]; then
	insmod /boot/ufs.o
    fi
    if [ "`fdisk -l | grep -i BEOS`" ]; then
	insmod /boot/bfs.o
    fi

# cycle thru devices
    for DEV in `ls --color=never /proc/ide/hd* -d | cut -d / -f 4`; do
	
# skip if not an harddisk
	if  [ `cat /proc/ide/$DEV/media` != disk ]; then continue; fi
	
# try to mount it (exits the script on success)
	mount_harddisk_system $DEV
	
	sync
	
    done

fi



###### CDROM

# CD filesystem is iso9660 unless we have a DVD (on xbox, for example)
CDFS="iso9660"
if [ ! -z "`uname -a | grep xbox`" ]; then
    echo "[*] searching dynebolic system on XBOX DVD"
    CDFS="udf"
else
    echo "[*] search dynebolic system on IDE CDROM devices"
fi

# cleanup paranoia: i always forget something there :^>
if [ -r /boot/dynecd ]; then rm -f /boot/dynecd; fi

for DEV in `ls --color=never /proc/ide/hd* -d | cut -d / -f 4`; do
    
    if  [ `cat /proc/ide/$DEV/media` != cdrom ]; then continue; fi
    
    mount_cdrom_system "$DEV"
    
    sync

done




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




if [ -z `mount | grep "type squashfs"` ]; then
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

exit 0 # FAILURE
