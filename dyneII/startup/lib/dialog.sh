# miscellaneous procedures called by dyne:bolic initialization scripts
# dialog functions
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



# do we really need it?
source /lib/dyne/utils.sh

dynedialog() {

   if [ -z $DISPLAY ]; then
	export TERM=linux
   fi

   dialog --colors --backtitle \
   "        dyne:II .:.:.:. `uname -rm` .:.:.:. RASTASOFT AFRO LINUX" \
   $@
}


dialog_bootlog() { dynedialog --tailbox /var/log/messages 30 90 }

# $1 = timeout
# $2 = text for message box
# return: -1 on timeout, 1 on yes, 0 on no
ask_yesno() {
   TTL=${1}
   dialog --timeout ${TTL} --colors --backtitle \
   "        dyne:II .:.:.:. `uname -rm` .:.:.:. RASTASOFT AFRO LINUX" \
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