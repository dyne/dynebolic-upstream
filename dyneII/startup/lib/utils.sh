# miscellaneous procedures called by dyne:bolic initialization scripts
#
# Copyleft 2003-2006 by Denis Rojo aka jaromil <jaromil@dyne.org>
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
  

# list of supported filesystems, used by:
# dynesdk - to copy the needed kernel modules in the initrd
# volumes.sh - to load the modules at startup, for mount autodetection
SUPPORTED_FS="fat,vfat,msdos,ntfs,ufs,befs,xfs,reiserfs,hfsplus,dm-mod"

# load dyne environmental variable
if [ -r /boot/dynenv ]; then source /boot/dynenv; fi

# load dyne language settings
if [ -r /etc/LANGUAGE ]; then source /etc/LANGUAGE; fi

# load dyne network settings
if [ -r /etc/NETWORK ]; then source /etc/NETWORK; fi

if [ -r /usr/bin/logger ]; then
  LOGGER=/usr/bin/logger
else
  LOGGER=/bin/logger
fi

notice() {
    $LOGGER -s -p syslog.notice "[*] ${1}"
}
act() {
    $LOGGER -s -p syslog.notice " .  ${1}"
}
error() {
    $LOGGER -s -p syslog.err    "[!] ${1}"
}
warning() {
    $LOGGER -s -p syslog.warn   "[W] ${1}"
}
xosd() {
    echo "${1}" | osd_cat -c lightblue -p middle -A center -s 3 \
      -f "-*-lucidatypewriter-*-*-*-sans-*-190-*-*-*-*-*-*" &
}

# udevstart populates and refreshes /dev directory
udevstart() {
  # regenerate events by triggering sysfs
#  for i in /sys/class/t*/*/uevent; do echo 1 > $i; done
  # wait for async events to finish
  #  while [ $(cat /proc/*/status 2> /dev/null | grep -c -E '^Name:.udevd?$') -gt 1 ]; do
  #      sleep 1
  #  done
#  for i in /sys/class/[!t]*/*/uevent; do echo 1 > $i; done
#  for i in /sys/block/*/uevent; do echo 1 > $i; done
#  if [ "`ls /sys/block | grep -vE 'ram|loop'`" ]; then
#    for i in /sys/block/*/*[1-9]/uevent; do echo 1 > $i; done
#  fi
#  for i in /sys/bus/*/devices/*/uevent; do echo 1 > $i; done

  # wait for async events to finish
#  while [ $(cat /proc/*/status 2> /dev/null | grep -c -E '^Name:.udevd?$') -gt 1 ]; do
#      sleep 1
#  done

udevtrigger
udevsettle

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

# dyne:II kernel module loading wrapper
# supports .gz and .bz2 compressed modules
# searches for modules in ramdisk and dock
# and at last in the usual /lib/modules
loadmod() {

    MODULE=${1}

    if [ $2 ]; then  # there are arguments
      MODARGS=`echo $@ | cut -d' ' -f 2-`
    else
      MODARGS=""
    fi

    # check if it is a denied module we skip
    MODULES_DENY="`get_config modules_deny`"
    for m in `iterate ${MODULES_DENY}`; do
        if [ x$MODULE = x$m ]; then
           act "$MODULE denied ... SKIPPED"
           return
        fi
    done

    # in interactive mode we ask 
    INTERACTIVE="`get_config modules_prompt`"
    if [ $INTERACTIVE ]; then 
	ask_yesno 10 "Load kernel module $MODULE ?"
	if [ $? = 1 ]; then
	    act "Loading kernel module $MODULE"
	else
	    act "Skipped kernel module $MODULE"
            return
	fi
    fi

    KRN=`uname -r`
    
    ##################################
    # look for the module in the docks
    if [ -r /boot/hdsyslist ]; then

      for HD in `cat /boot/hdsyslist | awk '{print $2}'`; do

        if [ -x ${HD}/dyne/kernel ]; then

          TRYMOD=`find ${HD}/dyne/kernel -name "${MODULE}"`

          if [ ${TRYMOD} ]; then

            insmod ${TRYMOD} ${MODARGS}
            if [ $? = 0 ]; then
              act "kernel module $MODULE loaded from docked dyne"
            else
              error "error loading kernel module $TRYMOD"
            fi
            return

          fi

        fi 

      done

    fi



    ################################
    # look for the module in ramdisk
    if [ -x /boot/modules/${KRN} ]; then

      TRYMOD=`find /boot/modules/${KRN} -name "${MODULE}.ko*"`
      if [ ${TRYMOD} ]; then
        # FOUND!
        mod_name=`basename ${TRYMOD}`
        if [ `echo ${mod_name} | grep ko.bz2` ]; then
          # it is a COMPRESSED module
          cd /boot/modules/${KRN}

          mod_name=`basename ${TRYMOD} .bz2`
          # uncompress it in /tmp
          bunzip2 -c ${TRYMOD} > ${mod_name}
          # load it
          insmod ${mod_name} ${MODARGS}
	  if [ $? = 0 ]; then
	    act "kernel module $TRYMOD $MODARGS loaded from ramdisk"
          else
            error "error loading kernel module $TRYMOD"
	  fi

          # remove the uncompressed module in /tmp
          rm -f ${mod_name}
          cd -
	  return 

        else # it's non-compressed in ramdisk

          insmod ${TRYMOD} ${MODARGS}
          if [ $? = 0 ]; then
            act "kernel module $MODULE loaded from ramdisk"
          else
            error "error loading kernel module $TRYMOD"
          fi
          return

        fi

      fi

    fi # the module it's not in the ramdisk

    ###############################################
    # look for the kernel module in the dyne modules
    if [ -x /opt ]; then
      for dynemod in `ls /opt`; do

        if [ -x /opt/${dynemod}/kernel ]; then

          TRYMOD=`find /opt/${dynemod}/kernel -name "${MODULE}.ko*"`
        
          if [ ${TRYMOD} ]; then

            insmod ${TRYMOD} ${MODARGS}
            if [ $? = 0 ]; then
              act "kernel module $MODULE loaded from ${dynemod}.dyne"
            else
              error "error loading kernel module $TRYMOD"
            fi
            return

          fi

        fi

      done

    fi

    ###############################################
    # at last if the system is mounted try modprobe
    if [ -x /usr/sbin/modprobe ]; then

#	if [ -r /etc/modules.deny ]; then
#	    if [ "`cat /etc/modules.deny | grep -E $1`" ]; then
#	        # skip modules included in /etc/modules.deny
#		act "skipping kernel module $MODULE (match in /etc/modules.deny)"
#		return
#	    fi
#	fi

        # finally we do it
	/usr/sbin/modprobe ${MODULE} ${MODARGS}
	if [ $? = 0 ]; then
	    act "kernel module $MODULE loaded with modprobe"
	else
	    error "error loading kernel module $MODULE"
	fi
	return
   
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

iterate_backwards() {
    echo "$1" | awk '
    BEGIN { FS = "," }
          { for(c=NF+1; c>0; c--) print $c }';
}
# I LOVE AWK \o/


# simple alphabet shell function by Jaromil
ALPHABET="abcdefghijklmnopqrstuvwxyz"
# takes an alphabet letter as argument
# can return the next or previous letter
# or simply the index position in the alphabet
# or if the argument is a number
#    returns the letter in the specified position of the alphabet
alphabet() { # args: letter (next|prev)

    IDX=`expr index $ALPHABET $1`

    if [ $IDX = 0 ]; then # number argument

	if [ "$2" = "next" ]; then
	    num="`expr $1 + 1`"
	elif [ "$2" = "prev" ]; then
	    num="`expr $1 - 1`"
	else
	    num=$1
	fi
	RES="`expr substr ${ALPHABET} $num 1`"

    elif   [ "$2" = "next" ]; then

	NUM="`expr ${IDX} + 1`"	
	RES="`expr substr ${ALPHABET} ${NUM} 1`"

    elif [ "$2" = "prev" ]; then

	NUM="`expr ${IDX} - 1`"
	RES="`expr substr ${ALPHABET} ${NUM} 1`"

    else
 	RES=${IDX}
    fi

    echo ${RES}
}


# checks if a mountpoint is mounted
is_mounted() { # arg: mountpoint or device
  mnt=$1
  grep ${mnt} /etc/mtab > /dev/null
  if [ $? = 0 ]; then
    echo "true"
  else
    echo "false"
  fi
}

# checks if a file is writable
# differs from -w coz returns true if does not exist but can be created
is_writable() { # arg: filename

  file=$1
  writable=false

  if [ -r $file ]; then # file exists

    if [ -w $file ]; then writable=true; fi

  else # file does not exist

    touch $file 1>/dev/null 2>/dev/null
    if [ $? = 0 ]; then
      writable=true
      rm $file
    fi 

  fi

  if [ x$writable = xtrue ]; then
    echo "true"
  else
    echo "false"
  fi
}

# checks if a process is running
# returns "true" or "false"
# arg 1: process name
is_running() {
  result="`ps ax | awk -v proc=$1 '$5 == proc { print "true"; found="yes" }
                                   END        { if(found!="yes") print "false" }'`"
  echo $result
}

# returns the file extension: all chars after the last dot
file_ext() {
  echo $1 | awk -F. '{print $NF}'
}

# appends a new line to a text file, if not duplicate
# it sorts alphabetically the original order of line entries
# defines the APPEND_FILE_CHANGED variable if file changes
append_line() { # args:   file    new-line

    # first check if the file is writable
    # this also creates the file if doesn't exists
    if [ `is_writable $1` = false ]; then
      error "file $1 is not writable"
      error "can't insert line: $2"
      return
    fi

    tempfile="`basename $1`.append.tmp"

    # create a temporary file and add the line there
    cp $1 /tmp/$tempfile
    echo "$2" >> /tmp/$tempfile

    # sort and uniq the temp file to temp.2
    cat /tmp/$tempfile | sort | uniq > /tmp/${tempfile}.2

    SIZE1="`ls -l /tmp/$tempfile | awk '{print $5}'`"
    SIZE2="`ls -l /tmp/${tempfile}.2 | awk '{print $5}'`"
    if [ $SIZE != $SIZE ]; then
      # delete the original
      rm -f $1
      # replace it
      cp -f /tmp/${tempfile}.2 $1
      # signal the change
      APPEND_FILE_CHANGED=true
    fi

    # remove the temporary files
    rm -f /tmp/$tempfile
    rm -f /tmp/${tempfile}.2
     
    # and we are done
}

cleandir() {
    DIR=${1}
    act "cleaning all files in ${DIR}"
    mkdir -p ${DIR}
    if [ "`ls -A ${DIR}/`" ]; then
	rm -rf ${DIR}/*
    fi
}

# $1 = timeout
# $2 = text for message box
# return: -1 on timeout, 1 on yes, 0 on no
ask_yesno() {
   TTL=${1}
   dialog --timeout ${TTL} --colors --backtitle \
   "        dyne:II .:.:.:. `uname -ormp` .:.:.:. RASTASOFT AFRO LINUX" \
   --yesno "$2" 0 0

   case $? in
     0) # yes
       return 1  ;;
     1) # no
       return 0  ;;
     *) # timeout or killed
       return -1 ;;
   esac
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

error_dialog() {
# popup an error dialog to notice the user
# args: message [icon]

  msg=$1
  icon=$2

  if [ -z $1 ]; then
    # quit if no argument
    return
  fi

  if [ -z $DISPLAY ]; then
    # if no display, just write on console
    error "$msg"
    return
  fi

  if [ -z $icon ]; then
    # if none specified use default icon
    icon="/usr/share/icons/graphite/48x48/gtk/gtk-dialog-error.png"
  fi

  export MAIN_DIALOG="
<vbox>
  <frame Error>
    <hbox>
      <pixmap>
        <input file>${icon}</input>
      </pixmap>
      <text>
        <label>${msg}</label>
      </text>
    </hbox>
  </frame>
  <button>
    <input file stock=\"gtk-close\"></input>
    <label>Abort operation</label>
  </button>

</vbox>
"

  gtkdialog --program=MAIN_DIALOG >/dev/null

}

fi # DYNE_SHELL_UTILS=included
