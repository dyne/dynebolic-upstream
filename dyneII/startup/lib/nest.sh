# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License

# nesting utilities

source /lib/dyne/utils.sh

choose_nest() {
    
    # first, if the "nest_partition" is set, then use partitions

    CFG_NEST="`get_config nest_partition`" # can be specified as /dev/hdXX or /vol/hdX

    if [ $CFG_NEST ]; then

      NEST_VOL=`cat /boot/volumes | grep $CFG_NEST`
      NEST_MNT=`echo $NEST_VOL | awk '{print $3}'`

      if ! [ -x $NEST_MNT ]; then
        error "nest partition $CFG_NEST is not mounted"
        return
      fi

      notice "using nest in $NEST_VOL"

      if [ "`mount | grep '/home'`" ]; then
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
# encryption is not yet supported: cryptoloop will be used
#	elif [ -r ${MNT}/dyne/dyne-aes.nst ]; then
#	    NEST="${MNT}/dyne/dyne-aes.nst"
#	    ENCRYPT="AES128"
	else unset NEST; fi

        if [ "`mount | grep '/home'`" ]; then
	  warning "nest already mounted, aborting operation"
	  return
        fi

	# mount nest in /mnt/nest
        mount_nest ${NEST}
    fi
    # bind directories in /mnt/nest to the filesystem

    if [ "`mount | grep /mnt/nest`" ]; then
      act "nest succesfully mounted"
      # this script shoud now link the directories
      bind_nest /mnt/nest

    else # no nest found, create system default

      notice "creating virtual nest in floating memory"

      if [ "`mount | grep '/home'`" ]; then
        warning "nest already mounted, aborting operation"
        return
      fi

      floating_nest

    fi
}




floating_nest() { 
  # setup a volatile nest environment
  # used when no nest is found

  notice "home and settings will be lost at reboot"
  notice "initializing virtual filesystem in memory"
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
  mkdir /var
  mount -o bind /dev/shm/var /var
		
  act "populating /home"
  mkdir -p /home /dev/shm/home
  mount -o bind /dev/shm/home /home
  mkdir -p /home/luther
  cp -ra /etc/skel/*    /home/luther/
  cp -ra /etc/skel/.*   /home/luther/
  chown -R luther:users /home/luther

  act "initializing /tmp"
  mkdir /dev/shm/tmp
  mount -o bind /dev/shm/tmp /tmp
		
}



bind_nest() { # arg:   path_to_mounted_nest
  # when a nest is already mounted somewhere
  # it binds it to the root filesystem
  # so this function shoud now link the directories

  NST=$1
  if ! [ -x $NST ]; then
    error "can't bind nest $NST: doesn't seems a directory"
    # switch to floating nest here?
    return
  fi

  # zap old logs
  if [ -r ${NST}/var/log/dyne.log ]; then
    rm ${NST}/var/log/dyne.log
  fi
  # wipe out /tmp
  if [ -x ${NST}/tmp ]; then
      rm -rf ${NST}/tmp/* 2>&1 >/dev/null
  fi
  # wipe out /var/run
  if [ -x ${NST}/var/run ]; then
      rm -rf ${NST}/var/run/* 2>&1 >/dev/null
  fi
  
  # bind home
  if [ ! -e /home ]; then mkdir /home; fi
  # we can also specify a single partition for home
  # in order to share a /home with another system
  if ! [ -e ${NST}/home ]; then
    warning "nest is missing home, skipping"
  else
    mount -o bind ${NST}/home /home
  fi

  # bind etc
  if [ ! -e ${NST}/etc ]; then
      warning "nest is missing etc, skipping"
  else
      cp -f /etc/mtab ${NST}/etc/mtab
      mount -o bind ${NST}/etc /etc
  fi

  # bind var
  if [ ! -e ${NST}/var ]; then
      warning "nest is missing var, skipping"
  else
      mount -o bind ${NST}/var /var
  fi

  # bind tmp
  if [ ! -e ${NST}/tmp ]; then
      warning "nest is missing tmp, skipping"
  else
      mount -o bind ${NST}/tmp /tmp
  fi

  DYNE_NEST_PATH=${NST}
  DYNE_NEST_VER="`cat /etc/DYNEBOLIC`"
  echo "export DYNE_NEST_VER=${DYNE_NEST_VER}"   >> /boot/dynenv
  echo "export DYNE_NEST_PATH=${DYNE_NEST_PATH}" >> /boot/dynenv

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
	    
	    act "mounting nest over loopback device"
	    mount -o loop ${NEST} /mnt/nest
	    if [ $? != 0 ]; then
	       error "mount failed with exitcode $?"
	       sleep 2
            fi
	fi
    fi	
}

