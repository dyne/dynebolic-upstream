#!/bin/sh
# mksdk.sh
# by bomboclat & c1cc10

WORKINGDIR=`pwd`

# Punto 1 
if ! [ -f $WORKINGDIR/stage1-x86-2004.1.tar.bz2 ] ; then
	wget ftp://ftp.belnet.be/mirror/rsync.gentoo.org/gentoo/releases/x86/2004.1/stages/x86/stage1-x86-2004.1.tar.bz2
fi
tar xvjf stage1-x86-2004.1.tar.bz2
# Fine punto 1

# Punto 2
mount -o bind /proc $WORKINGDIR/proc
#mount -o bind /dev $WORKINGDIR/dev
cp -a /etc/resolv.conf $WORKINGDIR/etc/
chroot $WORKINGDIR ./createbasesystem.sh
umount $WORKINGDIR/proc

