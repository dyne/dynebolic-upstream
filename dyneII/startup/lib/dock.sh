# dyne:II startup scripts
# (C) 2005-2006 Denis "jaromil" Rojo
# GNU GPL License

source /lib/dyne/dialog.sh

# this function prompts a selection dialog for the user
# to select which system to upgrade on the harddisk,
# it should be called when booting from CD on a system with multiple docks
update_multiple_docks() {
    CD="$1"
    c=0
    HDSYSLIST=`cat /boot/hdsyslist`

    MNT="`echo $CD|awk '{print $3}'`"
    source ${MNT}/dyne/VERSION
 
    rm -f /tmp/dialog /tmp/choice
    cat <<EOF > /tmp/dialog
"\n\nMultiple docked systems have been detected on your harddisk,\
 do you want to upgrade any of them?\n\n\n\n" 20 51 4
"No" "skip upgrading" "Don't upgrade any system on harddisk"
EOF
    for i in ${(f)HDSYSLIST}; do
	c=`expr $c + 1`
	dev=`echo $i| awk '{print $1}' | cut -d/ -f2`
	mnt=`echo $i| awk '{print $2}'`
	sys_ver=`echo $i| awk '{print $3}'`
	echo \
        "\"$mnt\" \"version $sys_ver on $dev\" \"upgrade the system on partition $c\"" \
	>> /tmp/dialog
    done

    # now render the dialog
    dynedialog --clear --item-help --title \
    "\Zr\Z0 Booting from CDROM system version $DYNE_SYS_VER " \
      --menu --file /tmp/dialog 2> /tmp/choice

    # fetch the selection
    sel=`cat /tmp/choice`
    rm -f /tmp/dialog /tmp/choice

    if [ "$sel" = "NO" ]; then return; fi

    if [ -x $sel ]; then
      notice "Upgrading system on harddisk $sel to version $DYNE_SYS_VER"
      act    "please wait while transferring files..."
      cp -rf ${MNT}/dyne ${sel}/dyne 
      act "done!"
    fi

}

choose_multiple_docks() {
	c=0
	syslist=`cat /boot/volumes | grep sys`
 
	rm -f /tmp/dialog /tmp/choice
	cat <<EOF > /tmp/dialog
"Multiple docked systems have been detected on your harddisks,\
 which one do you want to use?\
 \
" 20 51 4
EOF
	for i in ${(f)syslist}; do
		c=`expr $c + 1`
		dev=`echo $i| awk '{print $2}' | cut -d/ -f2`
		mnt=`echo $i| awk '{print $3}'`
                source ${mnt}/dyne/VERSION
		echo \
        	"\"$c\" \"version $DYNE_SYS_VER on $dev\" \"Use the system on partition $mnt\"" \
		>> /tmp/dialog
    	done

	# now render the dialog
	dynedialog --clear --item-help --title \
	"\Zr\Z0 Multi boot selection " \
	--menu --file /tmp/dialog 2> /tmp/choice

}


