#!/bin/sh
echo "[*] closing dyne:bolic session"

# Kill all processes.
# INIT is supposed to handle this entirely now, but this didn't always
# work correctly without this second pass at killing off the processes.
# Since INIT already notified the user that processes were being killed,
# we'll avoid echoing this info this time around.
if [ "$1" != "fast" ]; then # shutdown did not already kill all processes
   /sbin/killall5 -15
   /bin/sleep 5
   /sbin/killall5 -9
fi

# This is to ensure all processes have completed on SMP machines:
echo " .  wait to sync processes"
wait

echo " .  shutdown auto mounter daemon"
/usr/sbin/autofs stop

echo " .  release swap"
/usr/sbin/swapoff -a

echo " .  umount all volumes"
/bin/umount -a

echo " .  unload all kernel modules"
/sbin/rmmod -a

echo " .  sync harddrives" # this never hurts
/sbin/sync
# sleep 1 fixes problems with some hard drives that don't
# otherwise finish syncing before reboot or poweroff
/bin/sleep 1


