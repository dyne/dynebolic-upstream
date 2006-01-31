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


echo " .  unload all kernel modules"
for m in `lsmod | awk '!/Module/ {print $1}'`; do
  rmmod --force ${m}
done


echo " .  umount all volumes"
for vol in `unionctl /usr --list 2>&1 | awk '!/not.a.valid.union/ { print $1 }'`; do
  unionctl /usr --remove ${vol}
done
umount -a -d -f
umount -d -f /usr
if [ -x /mnt/usr ]; then
  umount -d -f /mnt/usr
fi

PATH=/bin:/sbin

echo " .  sync harddrives" # this never hurts
sync


if [ "$DYNE_SYS_MEDIA" = "cdrom" ]; then
    echo "[*] ejecting dyne:bolic cd"
    eject "$DYNE_SYS_DEV"
fi


if [ -r /boot/debug_shutdown ]; then
    /bin/ash
fi


# sleep 1 fixes problems with some hard drives that
# don't finish syncing before reboot or poweroff
sleep 1


echo "[*] POWER OFF"


