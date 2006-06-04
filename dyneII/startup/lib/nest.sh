# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License

# nesting utilities

source /lib/dyne/utils.sh


#### PUBLIC INTERFACE:
## this is the only function to be called outside of this script
## it will handle everything :) and at the end leave you with a /home and /etc
## either in RAM or from a nest

choose_nest() {

# TODO: encryption is not yet supported: cryptoloop should be used
#       please help here if you can ;)

    
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
	mount_nest ${nest_mnt}/dyne/dyne.nst

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
	  mount_nest ${nest_mnt}/dyne/dyne.nst
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
	      mount_nest ${nest_mnt}/dyne/dyne.nst
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
}




floating_nest() { 
  # setup a volatile nest environment
  # used when no nest is found

  notice "populating virtual filesystem in memory"
  act    "home and settings will be lost after reboot"
  RAMSIZE=`cat /proc/meminfo | awk '/MemTotal/{print $2}'`
  SHMSIZE=`expr $RAMSIZE / 1024 / 4`
  act "RAM detected: `expr $RAMSIZE / 1024` Mb"
  act "max VFS size: $SHMSIZE Mb"
  append_line /etc/fstab "tmpfs\t/dev/shm\ttmpfs\tdefaults,size=${SHMSIZE}m\t0\t0"
  mkdir -p /dev/shm # since 2.6.13 we need to create this dir by hand
  mount /dev/shm
		
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

  act "initializing /tmp"
  mkdir       /dev/shm/tmp
  chmod a+rwx /dev/shm/tmp
  chmod +t    /dev/shm/tmp

  act "loading /var"
  mv /var /dev/shm/var
  mkdir -p /var
	

  act "binding paths"
  mount -o bind /dev/shm/var  /var
  mount -o bind /dev/shm/root /root
  mount -o bind /dev/shm/home /home
  mount -o bind /dev/shm/tmp  /tmp

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
    warning "nest is missing root hideout, skipping"
  else
    mkdir -p /root # redundant
    mount -o bind ${NST}/root /root
  fi

  # bind etc
  if [ ! -e ${NST}/etc ]; then
      warning "nest is missing etc, skipping"
  else
      cp -f /etc/fstab ${NST}/etc/fstab
      cp -f /etc/mtab  ${NST}/etc/mtab
      mount -o bind ${NST}/etc /etc
  fi

  # bind var
  if [ ! -e ${NST}/var ]; then
      warning "nest is missing var, skipping"
  else
      # import logs
      cp -ra /var/log/* ${NST}/var/log/
      cleandir /var/log
      # wipe out /var/run
      if [ "`ls ${NST}/var/run`" ]; then
        cleandir ${NST}/var/run
        # just in case we have anything running in the ramdisk
        mv -f /var/run/* ${NST}/var/run/
      fi
      mount -o bind    ${NST}/var /var
  fi

  # bind tmp
  if [ ! -e ${NST}/tmp ]; then
      warning "nest is missing tmp, skipping"
  else
      # we wipe out /tmp at every boot
      cleandir ${NST}/tmp
      # it's called temporary, you've been warned.
      mount -o bind ${NST}/tmp /tmp
      chmod a+rwx /tmp
      chmod +t    /tmp
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

    if [ -r $nst ]; then

	    notice "activating dyne:bolic nest in ${nst}"

            act "nest filesystem check"
            fsck -TCp ${nst}
	    
	    act "mounting nest over loopback device"
	    mkdir -p /mnt/nest
	    mount -o loop ${nst} /mnt/nest
	    if [ $? != 0 ]; then
	       error "mount failed with exitcode $?"
            fi

    else
	error "no nest present in $NEST"
    fi
}

