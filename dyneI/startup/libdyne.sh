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

# module loading wrapper
loadmod() {
    if [ ! -z "`echo $KMOD_OUT | grep -E $1`" ]; then
	# skip modules included in /etc/modules.deny
	act "skipping kernel module $1 (match in KMOD_OUT)"
    elif [ -z "`grep interactive /proc/cmdline`" ]; then 
	# go straight, no interaction on module loading
	echo -n " .  loading kernel module $1 ... " | tee -a $LOG
	modprobe $1 1>>$LOG 2>>$LOG
	if [ $? = 0 ]; then
	    echo "OK" | tee -a $LOG
	else
	    echo
	    error "ERROR loading $1 kernel module"
	fi
    else
	# ask before loading each module
	echo -n "[?] load kernel module $1 " | tee -a $LOG
	getkey 10
	if [ $? = 1 ]; then echo " ... SKIPPED" | tee -a $LOG
#	elif [ $? = 2 ]; then echo " ... SKIPPED (timeout)" | tee -a $LOG
	else # YES, if y or any other key but 'n' is typed
	    modprobe $1 1>>$LOG 2>>$LOG
	    if [ $? = 0 ]; then
		echo " ... OK" | tee -a $LOG
	    else
		echo
		error "ERROR loading $1 kernel module"
	    fi
	fi
    fi
}




dyne_add_volume() {
  # $1 = media type (hdisk|floppy|usbkey|cd)
  # $2 = mount point
  VOLNUM=`expr $VOLNUM + 1`
  notice "adding $VOLNUM $1 volume on $2"
  WMCFG="/var/run/WMState"
  if [ -e /var/run/WMNum ]; then
      WMNUM="`cat /var/run/WMNum`"
  else WMNUM=1; fi

  case "$1" in
      "hdisk")
	  echo "," >> $WMCFG;
	  echo "{" >> $WMCFG;
	  echo "Name = \"$HDEV.HardDisk\";" >>$WMCFG;
	  echo "Lock = yes;" >>$WMCFG;
	  echo "Autolaunch = no;" >>$WMCFG;
	  echo "Command = \"xwc /vol/${2}\";" >>$WMCFG;
	  WMNUM="`expr $WMNUM + 1`"
	  echo "Position = \"0,${WMNUM}\";" >>$WMCFG;
	  echo "Forced = no;" >>$WMCFG;
	  echo "BuggyApplication = no;" >>$WMCFG;
	  echo "}" >>$WMCFG;
	  ;;
      "floppy")
	  echo "," >>$WMCFG;
	  echo "{" >> $WMCFG;
	  echo "Name = \"${2}.FloppyDisk\";" >>$WMCFG
	  echo "Lock = yes;" >>$WMCFG
	  echo "Autolaunch = no;" >>$WMCFG
	  echo "Command = \"xwc /rem/${2}\";" >>$WMCFG
	  WMNUM="`expr $WMNUM + 1`"
	  echo "Position = \"0,${WMNUM}\";" >>$WMCFG;
	  echo "Forced = no;" >>$WMCFG;
	  echo "BuggyApplication = no;" >>$WMCFG;
	  echo "}" >>$WMCFG;
	  ;;
      "usb")
	  echo "," >>$WMCFG;
	  echo "{" >> $WMCFG;
	  echo "Name = \"${2}.UsbStorage\";" >>$WMCFG
	  echo "Lock = yes;" >>$WMCFG
	  echo "Autolaunch = no;" >>$WMCFG
	  echo "Command = \"xwc /rem/${2}\";" >>$WMCFG
	  WMNUM="`expr $WMNUM + 1`"
	  echo "Position = \"0,${WMNUM}\";" >>$WMCFG;
	  echo "Forced = no;" >>$WMCFG;
	  echo "BuggyApplication = no;" >>$WMCFG;
	  echo "}" >>$WMCFG;
	  ;;
      "cd")
	  echo "," >>$WMCFG;
	  echo "{" >> $WMCFG;
	  echo "Name = \"${2}.CdRom\";" >>$WMCFG
	  echo "Lock = yes;" >>$WMCFG
	  echo "Autolaunch = no;" >>$WMCFG
	  echo "Command = \"xwc /rem/${2}\";" >>$WMCFG
	  WMNUM="`expr $WMNUM + 1`"
	  echo "Position = \"0,${WMNUM}\";" >>$WMCFG;
	  echo "Forced = no;" >>$WMCFG;
	  echo "BuggyApplication = no;" >>$WMCFG;
	  echo "}" >>$WMCFG;
	  ;;

      *)
	  error "invalid call to dyne_gen_wmaker_dock() in libdyne.sh"
	  return 0
	  ;;
  esac

  if [ -e /var/run/WMNum ]; then rm -f /var/run/WMNum; fi
  echo "$WMNUM" > /var/run/WMNum

}

