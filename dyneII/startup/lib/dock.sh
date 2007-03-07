# dyne:II startup scripts
# (C) 2005-2007 Denis "jaromil" Rojo
# GNU GPL License

source /lib/dyne/dialog.sh
source /lib/dyne/utils.sh



#######################
##  PRIVATE FUNCTIONS
## mount_dock() at the end of this file is called at boostrap
## the following private functions handle prompting to user

# this function prompts a selection dialog for the user
# to select which system to upgrade on the harddisk,
# it should be called when booting from CD on a system with multiple docks
update_multiple_docks() {
    CD="`cat /boot/volumes | grep -E 'cdrom.*sys'`"
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


check_hd_and_cd() {

    # *syslist format: dev mnt sys_ver init_ver

    cd_dev=`cat /boot/cdsyslist | awk '{print $1}'`
    cd_mnt=`cat /boot/cdsyslist | awk '{print $2}'`
    cd_sys_ver=`cat /boot/cdsyslist | awk '{print $3}'`
    cd_initrd_ver=`cat /boot/cdsyslist | awk '{print $4}'`

    hd_dev=`cat /boot/hdsyslist | awk '{print $1}'`
    hd_mnt=`cat /boot/hdsyslist | awk '{print $2}'`
    hd_sys_ver=`cat /boot/hdsyslist | awk '{print $3}'`
    hd_initrd_ver=`cat /boot/hdsyslist | awk '{print $4}'`

    # check if version differs between cd and hdisk
    ask_update=false;
    if [ "$cd_sys_ver" != "$hd_sys_ver" ]; then ask_update=true; fi
    if [ "$cd_initrd_ver" != "$hd_initrd_ver" ]; then ask_update=true; fi

    # prompt if upgrading from cd is desired
    if [ x$ask_update = xtrue ]; then

	ask_yesno 10 \
"the Dock on your harddisk is different from the CDROM:\n\n
CDROM :: sys $DYNE_SYS_VER :: init $DYNE_INITRD_VER\n
HDISK :: sys $HD_SYS_VER :: init $HD_INITRD_VER\n\n
Do you want to upgrade the system on your harddisk?"

	if [ $? = 1 ]; then
	    notice "upgrading harddisk system version to $DYNE_SYS_VER"
	    act "please wait while transferring files..."
	    HD_MNT="`cat /boot/hdsyslist|awk '{print $2}'`"
	    cp -rf ${cd_mnt}/dyne ${hd_mnt}/dyne
	    act "done!"
	else
	    act "Not upgrading from CD."
	fi

    fi

    # prompt if boot from cdrom or harddisk
    ask_yesno 10 "Do you want to boot from the system on your harddisk?"

    if [ $? != 0 ]; then

      DYNE_SYS_MEDIA=hdisk
      DYNE_SYS_DEV=${hd_dev}
      DYNE_SYS_MNT="${hd_mnt}/dyne"
      source ${DYNE_SYS_MNT}/VERSION
      notice "mounting the harddisk docked system on $DYNE_SYS_MNT"
      eject ${cd_dev}
      # device is already in the list of volumes
      # now add it to the fstab so that it will automount
      append_line /etc/fstab "${cd_dev}\t${cd_mnt}\tauto\tdefaults,user,ro\t0\t0"
      return

   else # boot from cd
	    
      DYNE_SYS_MEDIA=cdrom
      DYNE_SYS_DEV=${cd_dev}
      DYNE_SYS_MNT="${cd_mnt}/dyne"
      source ${DYNE_SYS_MNT}/VERSION
      notice "mounting the cdrom system on $DYNE_SYS_MNT"
      return

   fi
}


#################################################
### PUBLIC FUNCTIONS TO BOOTSTRAP


scan_dock_updates() {

  updates=`cat /boot/volumes | grep '^hdisk.*upd'`
  
  for upd in ${(f)updates}; do

    upd_dev=`echo $upd | awk '{print $2}' | basename`
    upd_mnt=`echo $upd | awk '{print $3}'`
    source ${upd_mnt}/dyne/update/VERSION

  ask_yesno 10 \
"the Dock on harddisk $upd_dev contains an update:\n\n
 dyne.sys version ${DYNE_SYS_VER}\n
 initrd.gz version ${DYNE_INITRD_VER}\n
 Do you want to apply it to the current system?"

  if [ $? = 1 ]; then
    src=${upd_mnt}/dyne/update
    dst=${upd_mnt}/dyne

    notice "updating docked system, please wait while copying files..."
    act "when complete, this computer will be rebooted."
    if [ -r $src/initrd.gz ]; then
      act "updating ramdisk"
      mv $src/initrd.gz* $dst/
    fi
    if [ -r $src/linux ]; then
      act "updating kernel"
      mv $src/*.krn     $dst/
      mv $src/*.kmods   $dst/
    fi
    if [ -r $src/dyne.sys ]; then
      act "updating core binary system"
      mv $src/dyne.sys*  $dst/
    fi

    if [ -x $src/modules ]; then
      act "updating modules"
      ls $src/modules
      mv $src/modules/* $dst/modules/
    fi

    # avoid to update next time
    rm $src/VERSION

    notice "UPDATE to $DYNE_SYS_VER / $DYNE_INITRD_VER COMPLETED"

  fi 

  done
}

# this function is called by the cdrom detection when a system is found on CD
# it goes thru the harddisks detected and check if they have a system
# match versions and ask user what to do if they are different
# (use cd | hd | update hd)
# setup DYNE_SYS_* variables in order to have the system mounted at the end
# of this script
#
# flowchart attempt:
#
# - check all HD, find system and schedule usage in $DYNE_SYS*
# - check all CD, check system version against all HD, query update
#                 if $DYNE_SYS* is not present, set $DYNE_SYS* to CD
#                 if $DYNE_SYS* is present, ask CD or HD
#
# sequence of conditionals:
# if (dock on hardisk) mount it
# else if (dock only on cd) mount it
# else if (dock on multiple media) choose

mount_dock() {

    # count the harddisk
    HDSYS=`cat /boot/volumes|grep -E '^hdisk.*sys'`
    HDSYS_NUM=0
    rm -f /boot/hdsyslist
    touch /boot/hdsyslist

    for v in ${(f)HDSYS}; do
	# volumes syntax: media device mount filesystem
	#        we want:       ^^^^^^ ^^^^^ ^^ TODO ^^ have fsys displayed at choice
	hd_dev="`echo $v|awk '{print $2}'`"
	hd_mnt="`echo $v|awk '{print $3}'`"

	# if the /mntpoint/dyne/VERSION is there, source it
	if [ -r ${hd_dev}/dyne/VERSION ]; then
	    # get versions: DYNE_SYS_VER DYNE_INITRD_VER
	    source ${hd_mnt}/dyne/VERSION
	fi

	# dev mnt sys_ver init_ver
	echo "${hd_dev} ${hd_mnt} $DYNE_SYS_VER $DYNE_INITRD_VER" >> /boot/hdsyslist
	HDSYS_NUM=`expr $HDSYS_NUM + 1`
    done
    
    # get the first cdrom
    CDSYS="`cat /boot/volumes|grep -E 'cdrom.*sys'`"
    CDSYS_NUM=0
    rm -f /boot/cdsyslist
    touch /boot/cdsyslist

    for v in ${(f)CDSYS}; do
	cd_dev="`echo $v|awk '{print $2}'`"
	cd_mnt="`echo $v|awk '{print $3}'`"

	# if the /mntpoint/dyne/VERSION is there, source it
	if [ -r ${cd_mnt}/dyne/VERSION ]; then
	    # get versions: DYNE_SYS_VER DYNE_INITRD_VER
	    source ${cd_mnt}/dyne/VERSION
	fi

	echo "${cd_dev} ${cd_mnt} $DYNE_SYS_VER $DYNE_INITRD_VER" >> /boot/cdsyslist
	CDSYS_NUM=`expr $CDSYS_NUM + 1`
    done
    

    if [ $HDSYS_NUM = 0 ]; then # no docks on harddisk ...

	if [ $CDSYS_NUM = 0 ]; then # ... and no cd
	    
	    error "no device containing the dyne:bolic system was detected"
	    return
	    
	else # ... and a cd found
	    
	    DYNE_SYS_MEDIA=cdrom
	    DYNE_SYS_DEV="`echo ${cd_dev}|awk '{print $2}'`"
	    DYNE_SYS_MNT="`echo ${cd_mnt}|awk '{print $3}'`/dyne"
	    return

	fi

    elif [ $HDSYS_NUM = 1 ]; then # ***** one dock on harddisk ...
	
	if [ $CDSYS_NUM != 0 ]; then # ... and there is a dyne cdrom

            check_hd_and_cd

	else # ... and there is no cdrom

	    DYNE_SYS_MEDIA=hdisk
	    DYNE_SYS_DEV="`cat /boot/hdsyslist|awk '{print $1}'`"
	    DYNE_SYS_MNT="`cat /boot/hdsyslist|awk '{print $2}'`/dyne"
	    source ${DYNE_SYS_MNT}/VERSION
	    notice "mounting the harddisk docked system on $DYNE_SYS_MNT"
	    return
	    
	fi

    else # ... there is more than one dock

	if [ $CDSYS_NUM != 0 ]; then # and there is a cdrom

	    # prompt if upgrading from cd is desired
            update_multiple_docks

	fi
	
        # prompt which dock has to be mounted
	choose_multiple_docks

        # fetch the selection
        sel=`cat /tmp/choice`
	    
	syslist=`cat /boot/volumes | grep sys`

	dock_sel=`echo $syslist | awk -v l=$sel 'NR == l { print $0 }'`

	act "dock selected: $dock_sel"

	DYNE_SYS_MEDIA=`echo $dock_sel | awk '{print $1}'`
	DYNE_SYS_DEV="`echo $dock_sel  | awk '{print $2}'`"
	DYNE_SYS_MNT="`echo $dock_sel  | awk '{print $3}'`/dyne"
	source ${DYNE_SYS_MNT}/VERSION
	notice "mounting the $DYNE_SYS_MEDIA docked system on $DYNE_SYS_MNT"

    fi
}

