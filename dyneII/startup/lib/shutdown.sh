#!/bin/ash

############################################
### dyne:II SHUTDOWN
### by Jaromil

# this should be run at halt and reboot and whenever
# the computer goes down, it also ejects the CD when present

PATH=/usr/bin:/usr/sbin:/bin:/sbin

echo "[*] closing dyne:bolic session"

# Kill all processes.
# INIT is supposed to handle this entirely now, but this didn't always
# work correctly without this second pass at killing off the processes.
# Since INIT already notified the user that processes were being killed,
# we'll avoid echoing this info this time around.
if [ "$1" != "fast" ]; then # shutdown did not already kill all processes
   killall5 -15
   sleep 5
   killall5 -9
fi


# This is to ensure all processes have completed on SMP machines:
echo " .  wait to sync processes"
wait


if [ -x /usr/sbin/swapoff ]; then
    echo " .  release swap"
    /usr/sbin/swapoff -a
fi

cd /

umount /mnt/nest

if [ -r /dev/mapper/dyne.nst ]; then # we have an encrypted nest
   # must unload the mapped device with cryptsetup
   cryptsetup luksClose dyne.nst
fi

mount | grep '^unionfs.*kmods'
if [ $? = 0 ]; then
  echo " .  umount unionfs overlay on kernel modules"
  unionctl "/lib/modules/`uname -r`" --remove /var/cache/union/kmods_rw
  unionctl /lib/modules/`uname -r` --remove "/mnt/.kmods/`uname -r`"
  sync
fi

echo " .  umount kernel modules"
umount "/lib/modules/`uname -r`"

mount | grep '^unionfs.*/usr'
if [ $? = 0 ]; then
  echo " .  umount unionfs overlay on /usr filesystem"
  unionctl /usr --remove /var/cache/union/usr_rw
  unionctl /usr --remove /mnt/usr
  sync
fi

echo " .  umount /usr filesystem"
umount /usr


PATH=/bin:/sbin

echo " .  umount all volumes"

umount -a


echo " .  unload all kernel modules"
for m in `lsmod | awk '!/Module/ {print $1}'`; do
  rmmod ${m}
done

if [ -x /usr/bin ];      then /bin/umount /usr         2>&1 > /dev/null; fi
if [ -x /mnt/usr/bin ];  then /bin/umount -d /mnt/usr  2>&1 > /dev/null; fi
if [ -x /mnt/nest/etc ]; then /bin/umount -d /mnt/nest 2>&1 > /dev/null; fi


echo " .  sync harddrives" # this never hurts
sync
# sleep 1 fixes problems with some hard drives that
# don't finish syncing before reboot or poweroff
sleep 1


if [ "$DYNE_SYS_MEDIA" = "cdrom" ]; then
    echo "[*] ejecting dyne:bolic cd"
    eject "$DYNE_SYS_DEV"
fi


if [ -r /boot/debug_shutdown ]; then
    /bin/ash
fi

if   [ -r /boot/halt ]; then
    /sbin/halt -ihdp
elif [ -r /boot/reboot ]; then
    /sbin/reboot
fi

