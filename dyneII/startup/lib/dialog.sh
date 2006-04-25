

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


