#!/bin/sh

#
# Bolic1 startup
#
# "$Id$"
	
CDFS="iso9660"

echo "[*] mounting /proc filesystem"
mount /proc

echo "[*] starting devfs daemon"
/sbin/devfsd /dev

if [ ! -z "`uname -a | grep xbox`" ]; then
  echo "[*] detected XBOX console"
  echo " .  mounting CD with UDF filesystem"
  CDFS="udf"
fi

echo "[*] mounting dynebolic from IDE CDROM"
for DEV in `ls --color=never /proc/ide/hd* -d | cut -d / -f 4`; do

   # IDE ATAPI CDROMS
   if [ `cat /proc/ide/$DEV/media` = cdrom ]; then

     echo " .  mounting $DEV"

     mount -t $CDFS -o ro /dev/$DEV /mnt/dynebolic

     echo " .  detecting squashed filesystem in ${DEV}"

     if [ -r /mnt/dynebolic/squashedfs ]; then

       echo " .  found! loading loopback device module"
       echo -n " .  " 
       if [ -z "`uname -a | grep xbox`" ]; then
         insmod /boot/loop-aes.o max_loop=128
       else
         insmod /boot/loop-aes-xbox.o max_loop=128
       fi

       echo " .  mounting squashedfs loopback filesystem"
       mount -o loop -t squashfs /mnt/dynebolic/squashedfs /usr
       if [ "$?" != "0" ]; then
         echo "[!] seems a problem occurred in mounting the squashedfs"
	 echo "[!] command issued was mount -o loop -t squashfs /mnt/dynebolic/squashedfs /usr"
	 echo "[!] this is fatal :("
       else
         echo "[*] dyne:bolic succesfully mounted from CD ${DEV}"
         if [ -e /boot/dynemount ]; then rm -f /boot/dynemount; fi
         echo "$DEV" > /boot/dynemount
       fi
       
     else # in case squashedfs is not found

       echo " .  not found, looking somewhere else"
       umount /mnt/dynebolic
       
     fi

   fi

   sync

   # TODO - SCSI CDROMS - please help, mail dynebolic@dyne.org

done

if [ ! -r /boot/dynemount ]; then
   echo "[!] dyne:bolic couldn't use your CD ROM player to boot correctly"
   echo "[!] maybe you are running on a system that's not supported yet?"
   echo "[!] arg, this is a fatal error :("
   echo "[!] means: it does'nt works on yours(tm)"
   echo "[!] try to ask for help on dynebolic@dyne.org"
   echo "[!] detailing your system configuration and settings."
   echo
   echo "[!] SCSI CD readers they don't work, we need help to develop"
   echo "[!] it is useful if you send us the output of the command"
   echo " .  dmesg | grep CD"
   echo "[!] from this console here"
   sleep 10
   echo "[!] this is a fatal error, going down now. bye."
   halt
fi

echo "[*] setup network loopback device"
ifconfig lo 127.0.0.1
