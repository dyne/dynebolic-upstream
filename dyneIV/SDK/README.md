# Simple Distro Kit for dyne:bolic IV

This directory contains scripts to operate on the distribution using
chroot and various other tools to access it read/write from remote.

To setup the SDK on a new machine use:

1. ./download.sh
2. ./setup.sh

Then to enter the chroot:

1. ./mount.sh
2. sudo chroot mnt
3. ./umount.sh

Always check that dev/proc/sys are not double mounted

TODO: Xrdp (remote desktop) and Xephyr (nested X) setups

