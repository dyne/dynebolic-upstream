#!/bin/ash
#
# generic shutdown script for dyne:bolic
# this should be run at halt and reboot and whenever
# the computer goes down, it also ejects the CD when present
#
# GNU GPL 2001-2005 by jaromil @ dyne.org
#

#source /lib/dyne/utils.sh
#source /boot/dynenv

PATH=/bin:/sbin

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

# shutdown automounter
if [ -x /etc/init.d/rc.autofs ]; then
  echo -n " .  "
  /etc/init.d/rc.autofs stop
fi

if [ -x /usr/sbin/swapoff ]; then
    echo " .  release swap"
    /usr/sbin/swapoff -a
fi

echo " .  unload all kernel modules"
rmmod -a

echo " .  umount all volumes"
umount -a

echo " .  sync harddrives" # this never hurts
sync

if [ $DYNE_SYS_MEDIA = "cdrom" ]; then
    echo "[*] ejecting dyne:bolic cd"
    eject "$DYNE_SYS_DEV"
fi


# sleep 1 fixes problems with some hard drives that
# don't finish syncing before reboot or poweroff
sleep 1


