#!/bin/sh
# mksdk.sh
# by bomboclat & c1cc10

WORKINGDIR=`dirname $0`

if [ "`whoami`" != "root" ]; then
    error "you must be ROOT on your machine to use dyne:bolic SDK"
    exit -1
fi

# Punto 1 
if ! [ -f $WORKINGDIR/stage1-x86-2004.1.tar.bz2 ] ; then
	wget ftp://ftp.belnet.be/mirror/rsync.gentoo.org/gentoo/releases/x86/2004.1/stages/x86/stage1-x86-2004.1.tar.bz2
fi
tar xvjf stage1-x86-2004.1.tar.bz2 -C $WORKINGDIR
# Fine punto 1

# Punto 2
mount -o bind /proc $WORKINGDIR/proc
#mount -o bind /dev $WORKINGDIR/dev
cp -a /etc/resolv.conf $WORKINGDIR/etc/
chroot $WORKINGDIR ./createbasesystem.sh
umount $WORKINGDIR/proc

