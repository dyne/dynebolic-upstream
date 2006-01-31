# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License

# nesting utilities

source /lib/dyne/utils.sh

choose_nest() {
    

    # TODO: kernel append option to mount a nest on partition
    # this is DEPRECATED for now
    # if the "nest_partition" config is set, then should use that partition
    CFG_NEST="`get_config nest_partition`" # can be specified as /dev/hdXX or /vol/hdX

    if [ $CFG_NEST ]; then

      NEST_VOL=`cat /boot/volumes | grep $CFG_NEST`
      NEST_MNT=`echo $NEST_VOL | awk '{print $3}'`

      if ! [ -x $NEST_MNT ]; then
        error "nest partition $CFG_NEST is not mounted"
        return
      fi

      notice "using nest in $NEST_VOL"

      if [ `is_mounted /home` = true ]; then
	warning "nest already mounted, aborting operation"
	return
      fi

      bind_nest ${NEST_MNT}

      if [ $DYNE_NEST_PATH ]; then
        act "nest succesfully mounted from partition"
	return
      fi

    fi







    # count the nests found in volumes
    NESTS=`cat /boot/volumes|grep nst`
    NESTS_NUM=0

    # extract the interesting array in /boot/nestlist
    for n in ${(f)NESTS}; do
	# volumes syntax: media device mount filesystem
	#        we want: ^^^^^        ^^^^^ ^^^^^^^^^^
	MEDIA="`echo $n|awk '{print $1}'`"
	MNT="`echo $n|awk '{print $3}'`"
	FSYS="`echo $n|awk '{print $4}'`"
	# media mnt fsys
	echo "$MEDIA $MNT $FSYS" >> /boot/nestlist
	NESTS_NUM=`expr $NESTS_NUM + 1`
    done

    if [ $NESTS_NUM = 0 ]; then
	notice "no nests were found on devices connected"
    else # NESTS_NUM > 0

        ### we found nests, they are listed in /boot/nestlist
	# media mnt fsys
        MNT=`cat /boot/nestlist|awk 'NR=1{print $2}'` 

        if [ -r ${MNT}/dyne/dyne.nst ]; then
    	    NEST="${MNT}/dyne/dyne.nst"
	    unset ENCRYPT
# TODO: encryption is not yet supported: cryptoloop should be used
#       please help here if you can ;)
#	elif [ -r ${MNT}/dyne/dyne-aes.nst ]; then
#	    NEST="${MNT}/dyne/dyne-aes.nst"
#	    ENCRYPT="AES128"
	fi

        if [ `is_mounted /home` = true ]; then
	  warning "nest already mounted, aborting operation"
	  return
        fi

	# mount nest in /mnt/nest
        mount_nest ${NEST}

# TODO: choice between multiple nests on the same system
#       here i plan a generic choice mechanism based on the format
#       of the /boot/nestlist and /boot/hdsyslist files (using AWK)

    fi

    # bind directories in /mnt/nest to the filesystem

    if [ `is_mounted /mnt/nest` = true ]; then

      act "nest succesfully mounted"
      # this script shoud now link the directories
      # here we kill the syslog and start a new one
      bind_nest /mnt/nest

    else # no nest found, create system default

      notice "creating virtual nest in floating memory"

      if [ `is_mounted /home` = true ]; then
        warning "nest already mounted, aborting operation"
        return
      fi

      floating_nest

    fi
}




floating_nest() { 
  # setup a volatile nest environment
  # used when no nest is found

  notice "populating virtual filesystem in memory"
  act    "home and settings will be lost at reboot"
  RAMSIZE=`cat /proc/meminfo | awk '/MemTotal/{print $2}'`
  SHMSIZE=`expr $RAMSIZE / 1024 / 4`
  act "RAM detected: `expr $RAMSIZE / 1024` Mb"
  act "VFS size: $SHMSIZE Mb"
  append_line /etc/fstab "tmpfs\t/dev/shm\ttmpfs\tdefaults,size=${SHMSIZE}m\t0\t0"
  mkdir -p /dev/shm # since 2.6.13 we need to create this dir by hand
  mount /dev/shm
		
  # creating /var /tmp and /home
  act "loading /var"
  mv /var /dev/shm/var
  mkdir -p /var
		
  act "populating /root"
  mkdir -p /root /dev/shm/root
  cp -ra /etc/skel/*    /dev/shm/root
  cp -ra /etc/skel/.*   /dev/shm/root
  chown -R root:root /dev/shm/root
  chmod -R go-rwx /dev/shm/root


  act "populating /home"
  mkdir -p /home /dev/shm/home/luther
  cp -ra /etc/skel/*    /dev/shm/home/luther/
  cp -ra /etc/skel/.*   /dev/shm/home/luther/
  chown -R luther:users /dev/shm/home/luther

  act "initializing /tmp"
  mkdir       /dev/shm/tmp
  chmod a+rwx /dev/shm/tmp
  chmod +t    /dev/shm/tmp


  act "binding new paths"
  mount -o bind /dev/shm/var  /var
  mount -o bind /dev/shm/root /root
  mount -o bind /dev/shm/home /home
  mount -o bind /dev/shm/tmp  /tmp

}



bind_nest() { # arg:   path_to_mounted_nest
  # when a nest is already mounted somewhere
  # it binds it to the root filesystem
  # so this function shoud now link the directories

  NST=$1
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
      mv -f /var/log/* ${NST}/var/log/
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
    NEST=${1}

    mkdir -p /mnt/nest

    if [ -r $NEST ]; then
	echo
	echo
	echo
	echo	
	echo -n "[?] use the dyne:bolic nest in ${NEST} (Y/n)"
	ask_yesno 10
	if [ $? = 0 ]; then
	    echo " ... SKIPPED"
	else
	    echo " ... OK"
	    
	    notice "activating dyne:bolic nest in ${NEST}"

            act "nest filesystem check"
            fsck -TCp ${NEST}
	    
	    act "mounting nest over loopback device"
	    mount -o loop ${NEST} /mnt/nest
	    if [ $? != 0 ]; then
	       error "mount failed with exitcode $?"
            fi
	fi
    fi	
}

