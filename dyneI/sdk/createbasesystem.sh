#!/bin/sh
# createbasesystem.sh
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

INSTDIR=/home/the_root

########################################################################
# standard output message routines
# it's always useful to wrap them, in case we change behaviour later
#
notice() { echo -e "\033[31m [*] $1\033[37m"; }
act() { echo "\033[32m . $1\033[37m"; }
error() { echo "\033[31m [!] $1\033[37m"; }
func() { if [ $DEBUG ]; then echo "\033[32m [D] $1\033[31m"; fi }


########################################################################
# MAIN FUNCTIONS
########################################################################

# get portage and bootstrap your compiling env 
function initrd_root() {
	if [ -d /usr/portage ] ; then
		notice "there is allready a dir '/usr/portage'. Should I use it?(N/s)"
		read YESNO
		if ! [ $YESNO == "s" -o $YESNO == "" ] ; then
			emerge sync
		fi
	else 
		emerge sync
	fi

	if ! [ -d /var/tmp/portage/ ] ; then
		/usr/portage/scripts/bootstrap.sh
	else 
		notice "esiste gia' /var/tmp/portage. hai gia' compilato il bootstrap?(S/n)"
		read YESNO
		if ! [ $YESNO == "S" -o $YESNO == "" ] ; then
			/usr/portage/scripts/bootstrap.sh
		fi
	fi
	emerge gentoolkit
	[ -d $INSTDIR ] || mkdir $INSTDIR
	# TODO avere baselayout-dynebolic.ebuild
	# ROOT=$INSTDIR emerge baselayout-dynebolic
	mkdir $INSTDIR/boot $INSTDIR/cdrom $INSTDIR/dev $INSTDIR/etc $INSTDIR/floppy $INSTDIR/home $INSTDIR/mnt \ 
		$INSTDIR/proc $INSTDIR/root $INSTDIR/usr $INSTDIR/var
	cp -a /var/db $INSTDIR/var
}

function set_flags() {
	notice "Quali CFLAG settiamo? default: '-O2 -mcpu=i586 -fomit-frame-pointer -pipe'"
	read CFLAG_SET
	[ -z $CFLAG_SET ] && export CFLAG_SET="-O2 -mcpu=i586 -fomit-frame-pointer -pipe" 
	act "$CFLAG_SET  ...ok! modifico /etc/make.conf"

cat > /etc/make.conf << EOF
# These settings were set by the catalyst build script that automatically built this stage
# Please consult /etc/make.conf.example for a more detailed example
CFLAGS="$CFLAG_SET"
CHOST="i586-pc-linux-gnu" 
CXXFLAGS="${CFLAGS}"
EOF

}

# install the base sources to have an initrd
function install_initrd_pkg () {
	
cat > /tmp/.initrd.lst << EOF
linux-headers
devfsd
glibc
ncurses
bash
coreutils
iputils
net-tools
EOF
	
for PKG in `cat /tmp/.initrd.lst` ; do
	ROOT=$INSTDIR emerge $PKG ;
done

rm /tmp/.initrd.lst 

}

# per ora con questo si ottiene un xfree con un tot di driver extra,
# bisognera' lavorarci per avere qualcosa di piu' nostro, se lo riteniamo.
# da considerarsi valido per ora, per avere una versione che funziona da subito.
function build_xfree() {
	set_flags
	ROOT=$INSTDIR USE='mmx sse 3dfx 3dnow' emerge ati-drivers

}

# TODO this function will be replaced with baselayout-dynebolic
function install_configuration_files(){
	if ! [ -f $WORKINGDIR/baselayout-db.tgz ] ; then
		wget http://www.autistici.org/bolic1/baselayout-db.tgz
	fi
	tar -zxvf baselayout-db.tgz -C $INSTDIR
	ROOT=$INSTDIR emerge baselayout-db
}
###############################################################################

##############################################################################
# Let's GO!
##############################################################################
# siamo dentro lo stage1. e' dove decidiamo i CFLAGS, per costruire prima l'ambiente di compilazione
# gentoo da cui poi deriviamo in /home/the_root la dynebolic.
# ogni aspetto l'abbiamo infilato in una funzione per auspicare uno sviluppo di ciascun passaggio

env-update

source /etc/profile

set_flags

initrd_root && notice "Ho completato l'SDK. Ora popolo l'initrd." || error "qualcosa e' andato storto. non e' stata colpa mia"

install_initrd_pkg && notice "Ho completato l'initrd_root..." || error "qualcosa e' andato storto. non e' stata colpa mia"

build_xfree  && notice "Ho completato l'initrd_root..." || error "qualcosa e' andato storto. non e' stata colpa mia"

# TODO this function will be replaced with baselayout-dynebolic
install_configuration_files && notice "Ho completato l'installazione delle configurazioni" || error "qualcosa e' andato storto. non e' stata colpa mia" 
