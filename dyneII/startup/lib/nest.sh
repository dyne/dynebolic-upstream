# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License

# nesting utilities

source /lib/dyne/dialog.sh
source /lib/dyne/utils.sh


#### PUBLIC INTERFACE:
## this is the only function to be called outside of this script
## it will handle everything :) and at the end leave you with a /home and /etc
## either in RAM or from a nest

choose_nest() {

    if [ `is_mounted /home` = true ]; then
	warning "script error"
	warning "choose_nest was called but a nest is already mounted in /home"
	return
    fi
    

    ###### CONFIG
    
    # if the "nest=/dev/hd*" config is set, then should use that partition

    cfg_nest="`get_config nest`" # can be specified as /dev/hd* or /mnt/hd*

    if [ $cfg_nest ]; then

      nest_vol=`cat /boot/volumes | grep $cfg_nest`
      notice "configured nest: $nest_vol"

      nest_mnt=`echo $nest_vol | awk '{print $3}'`

      if ! [ -x $nest_mnt ]; then

        error "nest partition $CFG_NEST is not mounted"

      elif ! [ -r $nest_mnt/dyne/dyne.nst ]; then

	error "no nest present in $NEST_MNT/dyne"

      else

	# loop-mount the nest in /mnt/nest
	mount_nest ${nest_mnt}/dyne/dyne.nst /mnt/nest

      fi
	
      # nest was succesfully mounted from the 'nest' kernel/config option
      if [ `is_mounted /mnt/nest` = true ]; then

        bind_nest

        if [ $DYNE_NEST_PATH ]; then

          act "nest succesfully mounted from partition"

	  return

        fi

      fi

    fi


    ###### AUTODETECT

    notice "autodetecting nest on mounted devices"

    # count the nests found in volumes
    nests=`cat /boot/volumes|grep nst`
    nests_num=0

    # extract the interesting array in /boot/nestlist
    for n in ${(f)nests}; do
	# volumes syntax: media device mount filesystem
	#        we want: ^^^^^        ^^^^^ ^^^^^^^^^^
	media="`echo $n|awk '{print $1}'`"
	mnt="`echo $n|awk '{print $3}'`"
	fsys="`echo $n|awk '{print $4}'`"
	# nestlist format: media mnt fsys
	echo "$media $mnt $fsys" >> /boot/nestlist
	# nests_num++
	nests_num=`expr $nests_num + 1`
    done


    ##### see what we have

    if [ $nests_num = 0 ]; then

	notice "no nests were found on devices connected"

    elif [ $nests_num = 1 ]; then # **** ... there is one nest

	# media [mnt] fsys
        nest_mnt=`cat /boot/nestlist|awk 'NR=1{print $2}'`

	rm -f /tmp/dialog /tmp/choice

        ask_yesno 10 \
"A nest has been found on this computer:\n\n
`cat /boot/nestlist`\n\n
Do you want to activate it?"
        if [ $? != 0 ]; then
	  mount_nest ${nest_mnt}/dyne/dyne.nst /mnt/nest
        fi
	
    else    

	###########################
	##### choose multiple nests

	c=0
        ### nests are listed in /boot/nestlist
	nestlist=`cat /boot/nestlist`

	### generate DIALOG for interactive selection
	rm -f /tmp/dialog /tmp/choice

	cat <<EOF > /tmp/dialog
"Multiple nests have been detected on your harddisks,\
 which one do you want to use?\
 (default is first after 10 seconds)" 20 51 4
EOF

	for i in ${(f)nestlist}; do
	    
	    # cycle thru nests and generate entries for the dialog
	    c=`expr $c + 1`
	    # nestlist format: media mnt fsys
	    media=`echo $i| awk '{print $1}'`
	    mnt=`echo $i| awk '{print $2}'`

            comment="last time modified: "
            comment+=`stat ${mnt}/dyne/dyne.nst | awk '/Modify/ { print $2 }'`
            if [ -r ${mnt}/dyne/VERSION ]; then

                source ${mnt}/dyne/VERSION
		comment+="  system ver. $DYNE_SYS_VER"

            fi

	    # calculate nest size / KB / MB
	    size=`stat $mnt/dyne/dyne.nst | awk '/Size/ {print $2}'`
	    size=`expr $size / 1024`
	    size=`expr $size / 1024`

	    echo \
"\"$c\" \"nest in $media $mnt (${size}MB)\" \"$comment\"" >> /tmp/dialog

	done

        # add no-nest choice
        c=`expr $c + 1`
        echo "\"$c\" \"don't use any nest\" \"run the system in volatile memory\"" >> /tmp/dialog

            # now render the dialog
	dynedialog --clear --item-help --title \
	    "\Zr\Z0 Multiple nest selection " \
	    --menu --file /tmp/dialog 2> /tmp/choice

	case $? in
	    0)
            # fetch the selection
	    sel=`cat /tmp/choice`
            nest_mnt=`echo $nestlist | awk -v l=$sel 'NR == l { print $2 }'`
            if [ $nest_mnt ]; then
              notice "selected nest in $nest_mnt"
              stat ${nest_mnt}/dyne/dyne.nst
	      mount_nest ${nest_mnt}/dyne/dyne.nst /mnt/nest
            else
              notice "not using any nest, running the system in RAM"
            fi
		;;
	    1)
		act "Cancel pressed: using virtual nest in RAM"
		;;
	    255)
		act "ESC pressed: using virtual nest in RAM"
		;;
	esac
	
    fi # END of multiple nest selection





    # bind directories in /mnt/nest to the filesystem

    if [ `is_mounted /mnt/nest` = true ]; then

      act "nest succesfully mounted"

      bind_nest

      if [ $DYNE_NEST_PATH ]; then
	  notice "nest succesfully activated"
      fi

    else # no nest found, create system default

      notice "no nest found, creating virtual nest in volatile memory"

      floating_nest

    fi


    # try first with tmp in docks
    tmps=`cat /boot/volumes | grep '^hdisk.*tmp' | awk '{print $3}'`
    for t in ${(f)tmps}; do
	if [ -w ${t}/dyne/tmp ]; then
           act "binding /tmp directory to harddisk storage"
           umount /tmp
	   mount -o bind,rw ${t}/dyne/tmp /tmp
           if [ $? != 0 ]; then
              error "error mounting tmp in harddisk ${t}"
           else
              cleandir /tmp
              chmod a+rwx /tmp
              chmod +t    /tmp
           fi
        fi
    done
        
}




floating_nest() { 
  # setup a volatile nest environment
  # used when no nest is found

  notice "floating nest: home and settings will be lost after reboot"
		
  ##############################
  # creating /var /tmp and /home
	
  act "populating /root"
  mkdir -p /root /dev/shm/root
  # default skel files
  cp -ra /lib/dyne/skel/*    /dev/shm/root
  cp -ra /lib/dyne/skel/.*   /dev/shm/root
  # permissions
  chown -R root:root /dev/shm/root
  chmod -R go-rwx /dev/shm/root
  # symlinks to utilities
  ln -s /lib/dyne/configure /dev/shm/root/Configure
  ln -s /mnt /dev/shm/root/Volumes

  act "populating /home"
  mkdir -p /home /dev/shm/home/luther
  # default skel files
  cp -ra /lib/dyne/skel/*    /dev/shm/home/luther/
  cp -ra /lib/dyne/skel/.*   /dev/shm/home/luther/
  # permissions
  chown -R luther:users /dev/shm/home/luther
  # symlinks to utilities
  ln -s /lib/dyne/configure /dev/shm/home/luther/Configure
  ln -s /mnt /dev/shm/home/luther/Volumes
	

  act "binding paths"
  mount -o bind /dev/shm/root /root
  mount -o bind /dev/shm/home /home

}



bind_nest() { # bind directories in /mnt/nest
  # before calling this function,
  # nest should be already mounted in /mnt/nest
  # this function binds the directories on the filesystem

  NST=/mnt/nest
  if ! [ -x $NST ]; then
    error "can't bind nest $NST: doesn't seems a directory"
    floating_nest
    return
  fi
  
  # bind home
  # TODO: we can also specify a single partition for home
  #       in order to share a /home with another system
  if ! [ -e ${NST}/home ]; then
    warning "nest is missing home, skipping"
  else
    mkdir -p /home # redundant
    mount -o bind ${NST}/home /home
  fi

  # bind root
  if ! [ -e ${NST}/root ]; then
    warning "nest is missing /root home directory, skipping"
  else
    mkdir -p /root # redundant
    mount -o bind ${NST}/root /root
  fi

  # bind etc
  if [ ! -e ${NST}/etc ]; then
      warning "nest is missing /etc, skipping"
  else
      cp -f  /etc/fstab ${NST}/etc/fstab
      cp -f  /etc/mtab  ${NST}/etc/mtab
      cp -fr /etc/pam.d ${NST}/etc/
      mount -o bind ${NST}/etc /etc
  fi

  # bind /usr/local
  if ! [ -e ${NST}/local ]; then
      warning "nest is missing /usr/local, skipping"
  else
      mkdir -p /usr/local # redundant
      mount -o bind ${NST}/local /usr/local
  fi

  DYNE_NEST_PATH=${NST}
  append_line /boot/dynenv "export DYNE_NEST_PATH=${DYNE_NEST_PATH}"

}



mount_nest() {
    nst=${1}
    mnt=${2}

    if [ -r $nst ]; then

	    notice "activating dyne:bolic nest in ${nst}"

	    mkdir -p ${mnt}
	    
	    act "mounting nest over loopback device"
	    nstloop=`losetup -f`
	    losetup -f ${nst}
	 
	    act "check if nest is a an encrypted LUKS device"
	    cryptsetup isLuks ${nstloop}
	    if [ $? = 0 ]; then # it's a LUKS encrypted nest, see cryptsetup(1)

                # check if key file is present
		if ! [ -r "${nst}.gpg" ]; then
		   error "secret encryption key is not present for this nest"
		   error "copy it in ${nst}.gpg"
                   losetup -d ${nstloop}
		   sleep 5
		   return
	        fi

                loadmod dm-crypt
                loadmod aes-i586

                mapper="nest.`date +%s`"

                notice "Password is required for nest in ${nst}"
                for c in 1 2 3 4 5; do

                  dialog --backtitle "Nest is encrypted for privacy protection" --title "Security check" \
                         --insecure --passwordbox "Enter password:" 10 30 2> /var/run/.scolopendro

                  cat /var/run/.scolopendro \
                     | gpg --passphrase-fd 0 --no-tty --no-options -d "${nst}.gpg" 2>/dev/null | grep -v passphrase \
                     | cryptsetup --key-file - luksOpen ${nstloop} ${mapper}

                  rm -f /var/run/.scolopendro

                  if [ -r /dev/mapper/${mapper} ]; then
                     break;  # password was correct
                  else
                     dialog --sleep 3 --infobox "password invalid, `expr 5 - $c` attempts left" 10 30
                  fi

                done

                if ! [ -r /dev/mapper/${mapper} ]; then
                  error "failure mounting the encrypted nest"
                  ls /dev
                  ls /var
                  tail /var/log/messages
                  losetup -d ${nstloop}
                  sleep 5
                  return
                fi
        	
                act "nest filesystem check"
                fsck.ext3 -p -C0 /dev/mapper/${mapper}
        
                mount -t ext3 /dev/mapper/${mapper} ${mnt}
                	
	    else 
	
                act "nest filesystem check"
                fsck.ext3 -p -C0 ${nst}
       
	        mount -t ext3 -o loop ${nst} ${mnt}

	        if [ $? != 0 ]; then
	           error "mount failed with exitcode $?"
                fi

            fi

    else
	error "no nest present in $NEST"
    fi
}

