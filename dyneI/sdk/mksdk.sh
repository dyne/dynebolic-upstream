#!/bin/sh
# -> mksdk.sh
#
# dyne:bolic software development kit - the commandline tool
#
# Copyright (C) 2004  Federico Prando bomboclat@malasystem.com
#                     Francesco Rana  c1cc10@malasystem.com
#                  
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
# Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
########################################################################
# standard output message routines
# it's always useful to wrap them, in case we change behaviour later
#
notice() { echo -e "\033[31m [*] $1\033[37m"; }
act() { echo "\033[32m . $1\033[37m"; }
error() { echo "\033[31m [!] $1\033[37m"; }
func() { if [ $DEBUG ]; then echo "\033[32m [D] $1\033[31m"; fi }
### END

CURRENTDIR=`dirname $0`
WORKINGDIR=mkdir -p $CURRENTDIR/dynebolic

# some checks
if [ "`whoami`" != "root" ]; then
    error "you must be ROOT on your machine to use dyne:bolic SDK"
    exit -1
fi


# Get the stage1 for your compiling environment
if ! [ -f $CURRENTDIR/stage1-x86-2004.1.tar.bz2 ] ; then
	act "do you have a valid stage1-$ARCH-xxx.tar.bz2 ?\nPlease provide '/full/path/to/it.bz2' or leave blank to download a brand new"
	read GIVE_PATH
	if [ -z "$GIVE_PATH" ] ; then
		wget ftp://ftp.belnet.be/mirror/rsync.gentoo.org/gentoo/releases/x86/2004.1/stages/x86/stage1-x86-2004.1.tar.bz2
	elif [ -f $GIVE_PATH ] ; then
		error "wrong path"
	fi
fi

tar xvjf stage1-x86-2004.1.tar.bz2 -C $WORKINGDIR

mount -o bind /proc $WORKINGDIR/proc
cp -a /etc/resolv.conf $WORKINGDIR/etc/
chroot $WORKINGDIR ./createbasesystem.sh
umount $WORKINGDIR/proc

