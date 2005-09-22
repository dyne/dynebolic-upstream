# miscellaneous procedures called by dyne:bolic initialization scripts
#
# Copyleft 2003-2005 by Denis Rojo aka jaromil <jaromil@dyne.org>
# with contributions by Alex Gnoli aka smilzo <smilzo@sfrajone.org>
# (this was started in one night hacking together in Metro Olografix)
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

# this script gets sourced by all dyne shell scripts
# we check here against multiple inclusion
if [ -z $DYNE_SHELL_UTILS ]; then
DYNE_SHELL_UTILS=included
  

# initialize logfile
LOG="/boot/startup.log"
if [ ! -r ${LOG} ]; then touch ${LOG}; fi

# list of supported filesystems, used by:
# dynesdk - to copy the needed kernel modules in the initrd
# volumes.sh - to load the modules at startup, for mount autodetection
SUPPORTED_FS="fat,vfat,msdos,ntfs,ufs,befs,jfs,reiserfs,usb-storage"

# load dyne environmental variable
if [ -r /boot/dynenv ]; then source /boot/dynenv; fi

# load dyne language settings
if [ -r /etc/LANGUAGE ]; then source /etc/LANGUAGE; fi


if [ -r /etc/NETWORK ]; then source /etc/NETWORK; fi

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


# configuration handling
# returns the value of a configuration variable
get_config() {
# check for a case insensitive match in the kernel options
# to allow overriding of all settings from boot prompt.
    KERNEL_VAL=`cat /proc/cmdline | awk -v name="$1" '
BEGIN { FS = "="; RS = " "; IGNORECASE = 1; variable = name; }
$1 == variable { print $2; }
'`
    if [ $KERNEL_VAL ]; then
	echo "${KERNEL_VAL}"
	return 0
    fi

    # environmental variable set dinamicly may override config
    ENV_VAL=`export | awk -v name="$1" '
BEGIN { FS = "="; IGNORECASE = 1; variable = name; }
$1 == variable { print $2; }
'`
    if [ $ENV_VAL ]; then
	echo "${ENV_VAL}"
	return 0
    fi

    # check if there is a config file in our dock
    # if yes take the configuration from that
    if [ -r $DYNE_SYS_MNT/dyne.cfg ]; then
	CFG_VAL=`cat $DYNE_SYS_MNT/dyne.cfg | awk -v name="$1" '
BEGIN { FS = "="; IGNORECASE = 1; variable = name; }
$1 == variable { print $2; }
'`
	if [ $CFG_VAL ]; then
	    echo "${CFG_VAL}"
	    return 0
	fi

    fi
	
    return 1
}


# module loading wrapper
loadmod() {

    MODULE=${1}

    # check if it is a denied module we skip
    MODULES_DENY="`get_config modules_deny`"
    for m in `iterate ${MODULES_DENY}`; do
        if [ $MODULE = $m ]; then
           act "$MODULE denied ... SKIPPED"
        fi
    done

    # in interactive mode we ask 
    INTERACTIVE="`get_config modules_prompt`"
    if [ $INTERACTIVE ]; then 
	echo -n "[?] do you want to load kernel module $MODULE [y/N] ?" | tee -a $LOG
	ask_yesno 10
	if [ $? = 1 ]; then
	    echo " ... SKIPPED" | tee -a $LOG
	    return
	else
	    echo " ... LOADED" | tee -a $LOG
	fi
    fi

    # if the system is mounted
    if [ -x /usr/sbin/modprobe ]; then
	if [ -r /etc/modules.deny ]; then
	    if [ "`cat /etc/modules.deny | grep -E $1`" ]; then
	    # skip modules included in /etc/modules.deny
		act "skipping kernel module $MODULE (match in /etc/modules.deny)"
		return
	    fi
	fi

    # finally we do it
	/usr/sbin/modprobe ${MODULE} 1>>$LOG 2>>$LOG
	if [ $? = 0 ]; then
	    act "loaded kernel module $MODULE"
	    return
	else
        # no error output to console
	# "i panni sporchi si lavano in famiglia"
	    echo "[!] ERROR loading kernel module $MODULE" >> $LOG
	fi
    
    else # if we are in volatile mode (system not yet mounted)
	
	# look for the module in /boot/modules/$KRN
	KRN=`uname -r`
	TRYMOD=`find /boot/modules/${KRN} -name "${MODULE}*"`
	if [ -r ${TRYMOD} ]; then
	    insmod ${TRYMOD} 1>>$LOG 2>>$LOG
	    if [ $? = 0 ]; then
		act "loaded kernel module $MODULE"
		return 
	    fi
	fi
	# look for the module in all harddisks
        if [ -r /boot/hdsyslist ]; then
	  for HD in `cat /boot/hdsyslist | awk '{print $2}'`; do
	    TRYMOD=`find /vol/${HD}/dyne -name "${MODULE}.ko"`
            if [ -r ${TRYMOD} ]; then
               insmod ${TRYMOD} 1>>$LOG 2>>$LOG
	       if [ $? = 0 ]; then
	 	  act "loaded kernel module $MODULE"
		  return 
	       fi
            fi
	  done
        fi
    fi

    error "kernel module $MODULE not found"
}


# iterates the values of a comma separated array on stdout
# (good for use in for cycles on modules lists)
iterate() {
    echo "$1" | awk '
    BEGIN { RS = "," }
          { print $0 }';
}

# appends a new line to a text file, if not duplicate
append_line() { # args:   file    new-line

    if [ `grep '$2' '$1'` ]; then  return;  fi

    if ! [ -w $1 ]; then
      error "file $1 is not writable"
      error "can't add line: $2"
      return
    fi

    # finally add it at the end
    echo "$2" >> $1

}

# $1 = timeout
# $2 = (optional) yes key
# $3 = (optional) no key
# return: -1 on timeout, 1 on yes, 0 on no
ask_yesno() {
   TTL=${1}

   if [ -z ${2} ]; then YES=y
   else YES=${2}; fi

   if [ -z ${3} ]; then NO=n
   else NO=${3}; fi
   
   while [ true ]; do
       CHOICE="`getkey ${TTL}`"
       if [ "$CHOICE" = "~" ]; then return -1; fi
       if [ "$CHOICE" = "$YES" ]; then return 1; fi
       if [ "$CHOICE" = "$NO" ]; then return 0; fi
   done
}

# $1 = timeout
# $2 = max choice number
# return: -1 on timeout, choice number on success
ask_choice() {
    TTL=${1}
    MAX=${2}
    CHOICE=0

    while [ true ]; do
	CHOICE="`getkey ${TTL}`"
	if [ "$CHOICE" = "~" ]; then # timeout
	    return -1
	fi

	C=${MAX}
	while [ $C != 0 ]; do
	    if [ ${CHOICE} = ${C} ]; then
		return ${CHOICE}
	    fi
	    C=`expr $C - 1`
	done
    done
}


fi # DYNE_SHELL_UTILS=included
