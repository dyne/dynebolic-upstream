#!/bin/sh
#
# miscellaneous procedures called by dyne:bolic initialization scripts
#
# Copyleft 2003-2004 by Denis Rojo aka jaromil <jaromil@dyne.org>
# with contributions by Alex Gnoli aka smilzo <smilzo@sfrajone.org>
# (this was started in one night hacking together in metro olografix)
#
#  * freely distributed in dyne:bolic GNU/Linux http://dynebolic.org
#  * 
#  * This source code is free software; you can redistribute it and/or
#  * modify it under the terms of the GNU Public License as published 
#  * by the Free Software Foundation; either version 2 of the License,
#  * or (at your option) any later version.
#  *
#  * This source code is distributed in the hope that it will be useful,
#  * but WITHOUT ANY WARRANTY; without even the implied warranty of
#  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#  * Please refer to the GNU Public License for more details.
#  *
#  * You should have received a copy of the GNU Public License along with
#  * this source code; if not, write to:
#  * Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


LIBDYNE_ID="\$Id$"
PATH="/bin:/sbin:/usr/bin:/usr/sbin"

# initialize logfile
LOG="/var/log/dynebolic.log"
if [ ! -r ${LOG} ]; then
    LOG="/boot/dynebolic.log"
    if [ ! -r ${LOG} ]; then touch ${LOG}; fi
fi

# load dynebolic environmental variable
if [ -r /boot/dynenv ]; then source /boot/dynenv; fi

# load dynebolic language settings
if [ -r /etc/LANGUAGE ]; then source /etc/LANGUAGE; fi


# logging functions
if [ ! -z $FILE_ID ]; then
    echo >> $LOG
    echo "RC: $FILE_ID" >> $LOG
    echo >> $LOG
fi

notice() {
    echo "[*] ${1}" | tee -a $LOG
}
act() {
    echo " .  ${1}" | tee -a $LOG
}
error() {
    echo "[!] ${1}" | tee -a $LOG
}
warning() {
    echo "[W] ${1}" | tee -a $LOG
}


# module loading wrapper
loadmod() {
    if [ -r /etc/modules.deny ]; then
      if [ "`cat /etc/modules.deny | grep -E $1`" ]; then
	# skip modules included in /etc/modules.deny
	act "skipping kernel module $1 (match in /etc/modules.deny)"
	return
      fi
    fi
    # in interactive mode we ask 
    if [ "`grep -i interactive /proc/cmdline`" ]; then 
 	echo -n "[?] do you want to load kernel module $1 " | tee -a $LOG
	getkey 10
	if [ $? = 1 ]; then
	    echo " ... SKIPPED" | tee -a $LOG
	    return
	else
	    echo " ... LOADED" | tee -a $LOG
	fi
    fi 
    # finally we do it
    modprobe $1 1>>$LOG 2>>$LOG
    if [ $? = 0 ]; then
        act "loaded kernel module $1"
    else
        # no error output to console
	# "i panni sporchi si lavano in famiglia"
        echo "[!] ERROR loading kernel module $1" >> $LOG
    fi
}


