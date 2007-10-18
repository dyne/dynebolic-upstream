# dyne:II startup scripts
# (C) 2005-2006 Denis "jaromil" Rojo
# GNU GPL License

source /lib/dyne/utils.sh

add_volume() {
  # $1 = media type (hdisk|floppy|usb|cdrom)
  # $2 = device
  # $3 = mount point
  # $4 = filesystem

  MEDIA=${1}
  DEV=${2}
  MNT=${3}
  FS=${4}

  KRN=`uname -r`

  if [ ! -r /boot/volumes ]; then touch /boot/volumes; fi

  FLAGS=""
  DOCK=dyne

  PFX=/mnt
  mkdir -p ${PFX}/${MNT}

  PASS=2
  # check for a dock
  if [ -x ${PFX}/${MNT}/${DOCK} ]; then
      if [ -r ${PFX}/${MNT}/${DOCK}/dyne.sys ]; then FLAGS="$FLAGS sys"; fi
      if [ -r ${PFX}/${MNT}/${DOCK}/dyne.nst ]; then FLAGS="$FLAGS nst"; fi
      if [ -r ${PFX}/${MNT}/${DOCK}/dyne.nst.gpg ]; then FLAGS="$FLAGS key"; fi
      if [ -r ${PFX}/${MNT}/${DOCK}/dyne.cfg ]; then FLAGS="$FLAGS cfg"; fi
      if [ -x ${PFX}/${MNT}/${DOCK}/SDK ];      then FLAGS="$FLAGS sdk"; fi
      if [ -r ${PFX}/${MNT}/${DOCK}/linux-${KRN}.kmods ]; then FLAGS="$FLAGS krn"; fi
      if [ -x ${PFX}/${MNT}/${DOCK}/tmp ]; then FLAGS="$FLAGS tmp"; fi
      if [ -r ${PFX}/${MNT}/${DOCK}/rc.local ]; then FLAGS="$FLAGS rcl"; fi
      if [ -r ${PFX}/${MNT}/${DOCK}/update/VERSION ]; then FLAGS="$FLAGS upd"; fi
      if [ -x ${PFX}/${MNT}/${DOCK}/modules ]; then FLAGS="$FLAGS mod"; fi
  fi
  # samba mounts wont contain a dyne directory, so we check the root
  if ! [ $FLAGS ]; then  # we do it in case nothing was found so far
      if [ -r ${PFX}/${MNT}/dyne.sys ]; then FLAGS="$FLAGS sys"; fi
      if [ -r ${PFX}/${MNT}/dyne.nst ]; then FLAGS="$FLAGS nst"; fi
      if [ -r ${PFX}/${MNT}/dyne.nst.gpg ]; then FLAGS="$FLAGS key"; fi
      if [ -r ${PFX}/${MNT}/dyne.cfg ]; then FLAGS="$FLAGS cfg"; fi
      if [ -x ${PFX}/${MNT}/SDK ];      then FLAGS="$FLAGS sdk"; fi
      if [ -r ${PFX}/${MNT}/linux-${KRN}.kmods ]; then FLAGS="$FLAGS krn"; fi
      if [ -x ${PFX}/${MNT}/tmp ]; then FLAGS="$FLAGS tmp"; fi
      if [ -r ${PFX}/${MNT}/rc.local ]; then FLAGS="$FLAGS rcl"; fi
      if [ -x ${PFX}/${MNT}/modules ]; then FLAGS="$FLAGS mod"; fi
      # no update for rooted docks, mostly online mounted 
  fi


  if [ $FLAGS ]; then PASS=1; fi # check filesystem if sys|nst|cfg|sdk

  case ${MEDIA} in

      "hdisk")
	  append_line /boot/volumes "${MEDIA} /dev/${DEV} ${PFX}/${MNT} ${FILESYS} ${FLAGS}"
          # $FILESYS and $OPTIONS were set in scan_partitions()
	  append_line /etc/fstab "/dev/${DEV}\t${PFX}/${MNT}\t${FILESYS}\t${OPTIONS}\t0\t${PASS}"
	  ;;


# floppy, usb and cdrom are mounted in /rem
      
      "floppy")
	  append_line /boot/volumes "${MEDIA} /dev/${DEV} ${PFX}/${MNT} ${FS}"
	  append_line /etc/fstab "/dev/${DEV}\t${PFX}/${MNT}\tmsdos\tdefaults,noauto,user,sync\t0\t0"
	  ;;
     
 
      "usb")
	  append_line /boot/volumes "${MEDIA} /dev/${DEV} ${PFX}/${MNT} auto ${FLAGS}"
	  append_line /etc/fstab "/dev/${DEV}\t${PFX}/${MNT}\tauto\t${OPTIONS},defaults,user,sync\t0\t${PASS}"
	  ;;

      
      "cdrom"|"dvd")
	  append_line /boot/volumes "${MEDIA} /dev/${DEV} ${PFX}/${MNT} ${FS} ${FLAGS}"
	  append_line /etc/fstab \
          "/dev/${DEV}\t${PFX}/${MNT}\tauto\tdefaults,user,ro\t0\t0"
	  ;;

      "samba")
          append_line /boot/volumes "$MEDIA ${DEV} ${PFX}/${MNT} ${FS} ${FLAGS}"
          append_line /etc/fstab \
          "//${DEV}/dyne.dock\t${PFX}/${MNT}\tsmbfs\tguest,ro,ttl=10000,sock=IPTOS_LOWDELAY,TCP_NODELAY\t0\t0"
          ;;
      

      *)
	  error "unknown media type ${MEDIA} for add_volume"
	  return 1
	  ;;
  esac
  
  act "${MEDIA} volume on ${PFX}/${MNT}"
  
  return 0
}


###### CDROM

CD_NUM=0
DVD_NUM=0

SYS_CD_FOUND=false
scan_cdrom() {

# CD filesystem is iso9660 unless we have a DVD (on xbox, for example)
    if [ "`uname -a | grep xbox`" ]; then
	act "xbox dvd filesystem: udf"
	CDFS="udf"
    else
	act "ide cdrom filesystem: auto"
	CDFS="auto"
    fi
    

    # scan for ide devices
    for DEVPATH in `ls /proc/ide | awk '/^hd.*/ {print $1}'`; do

        DEV=`basename ${DEVPATH}`

	# if it's not a cdrom then skip it
	if  [ `cat /proc/ide/$DEV/media` != cdrom ]; then continue; fi

	if [ "`dmesg|grep '$DEV.*DVD'`" ]; then 
	    MEDIA=dvd
	    DVD_NUM=`expr $DVD_NUM + 1`
	    MNT=dvd${DVD_NUM}
	else
	    MEDIA=cdrom
	    CD_NUM=`expr $CD_NUM + 1`
	    MNT=cd${CD_NUM}
	fi
	
	act "scanning ${DEV} -> ${MNT} (${CDFS})"
	
	mkdir -p /mnt/${MNT}

	mount -t ${CDFS} -o ro /dev/${DEV} /mnt/${MNT} 2>/dev/null 1>/dev/null

	if [ $? != 0 ]; then # device was not mounted

	    # media is not found inside, delete dir
	    # and add the CD as automount device
	    add_volume ${MEDIA} ${DEV} ${MNT} ${CDFS}

	elif [ -r /mnt/${MNT}/dyne/dyne.sys ]; then # device contains dyne sys
	    	    
            # leave it mounted and add it to the list of volumes
	    add_volume ${MEDIA} ${DEV} ${MNT} ${CDFS}
	    
	else # device has a CD inside, not the dyne one

	    # unmount it and add it to automount devices
	    umount /mnt/${MNT}
	    add_volume ${MEDIA} ${DEV} ${MNT} ${CDFS}

	fi
	    	
    done
}


###### HARDDISK

scan_partitions() { #arg : devicename (hotplug)
    # scans a list of fdisk format partitions
    PART_NUM=0
    DEV=`basename $1`

    # check which fdisk to use
    FDISK=fdisk
    if [ "`${FDISK} -l /dev/${DEV} 2>&1| \
           grep -i 'doesn.t contain a valid partition table'`" ]; then
      # try mac
      FDISK=fdisk-pmac
      if [ "`${FDISK} -l /dev/${DEV} 2>&1| \
             grep -i 'doesn.t contain a valid partition table'`" ]; then
        error "can't parse partition table of drive ${DEV}"
        return
      fi
    fi


    PARTITIONS=`${FDISK} -l /dev/${DEV}            \
              | sed -e 's/ \* / /'              \
              | awk '/^\/dev\/*/ { if(NF!=1) print $0 }' \
              | grep -Evi 'extended|ext.d|swap|partition.map|free.space|diagnostics'`
    
        # cycle thru partitions
        # ${(f)..} splits the result of the expansion to lines. see: man zshexpn
    for PART in ${(f)PARTITIONS}; do
	
	
	PART_FS="`echo $PART|awk '{print $6 " " $7 " " $8}'`"
        PART_DEV="`echo $PART|cut -d' ' -f1`"
	
	PART_NUM=`expr $PART_NUM + 1`
	
	
        # skip it if already mounted as root (partition install)
        if [ "$ROOT_PART" = "$PART_DEV" ]; then
	    
	    act "$PART_FS partition $PART_DEV already mounted as root"
	    continue
	    
        fi 

        if [ "$2" = "hotplug" ]; then
	  MNT="/mnt/usb${HD_NUM}/${PART_NUM}"
        else
	  MNT="/mnt/hd${HD_NUM}/${PART_NUM}"
        fi

	mkdir -p ${MNT}

	# mount the partition only if not already mounted
	if [ `is_mounted ${PART_DEV}` = true ]; then

          act "skipping partition ${PART_DEV}: already mounted"

        else

          act "mounting ${PART_FS} partition ${PART_DEV}"

	  do_fsck="`get_config fsck`"
	  if ! [ "$do_fsck" = "false" ]; then
          # starts a check on linux ext* filesystems
	      if [ "`echo $PART|grep -iE 'linux'`" ]; then
		  notice "linux filesytem check"
            # man fsck says this should safely work
		  fsck -TCp ${PART_DEV}
	      fi  
	  fi
	   
          # here check if FS ~= LVM then use LVM-tools
          if [ "`echo ${PART_FS}   | grep 'LVM'`" ]; then
            # it's a LVM, see LVM-Howto online..
            # long story made simple: this is our automatic LVM support :)
            # dm-mod kernel module is inside the ramdisk
            # /sbin/lvm is present
            # the following commands are necessary to activate the support:
            #   dmsetup mknodes
            #   vgscan --ignorelockingfailure
            #   vgchange -ay --ignorelockingfailure

            dmsetup mknodes
            /sbin/lvm.apps/vgscan --ignorelockingfailure
            /sbin/lvm.apps/vgchange -ay --ignorelockingfailure

            volumes=`/sbin/lvm.apps/lvdisplay | awk '/LV Name/ { print $3 }'`

            # +-1 trix
	    PART_NUM=`expr $PART_NUM - 1`

            for vol in ${(f)volumes}; do

	      PART_NUM=`expr $PART_NUM + 1`
	      
	      MNT="/mnt/hd${HD_NUM}/${PART_NUM}"

	      mkdir -p ${MNT}

              mount $vol $MNT

              if [ $? != 0 ]; then
	        error "can't mount ${vol} : not a valid filesystem"
	        continue
	      fi

	      add_volume hdisk `basename ${vol}` hd${HD_NUM}/${PART_NUM} auto

            done 

            continue
          #################### LVM
          
          # here check if FS ~= NTFS then use umask=0222
	  elif [ "`echo ${PART_FS}   | grep -i 'NTFS'`" ]; then
	    OPTIONS="rw,uid=0,gid=8,umask=0002"
	    FILESYS="ntfs-3g"

          # and here check if FS ~= bsd44
	  elif [ "`echo ${PART_FS} | grep -iE 'BSD|ufs'`" ]; then
	    OPTIONS="ro,ufstype=44bsd"
	    FILESYS="ufs"

          # FAT
          elif [ "`echo ${PART_FS} | grep -i 'FAT'`" ]; then
            OPTIONS="rw,noexec,uid=0,gid=8,umask=0002"
            FILESYS="vfat"

          # linux filesystems have granular permissions
          elif [ "`echo ${PART_FS} | grep -iE 'linux|reiser|xfs'`" ]; then
            OPTIONS="defaults"
            FILESYS="auto"

          # all the others
	  else
	    OPTIONS="defaults,uid=0,gid=8,umask=0002"
	    FILESYS="auto"
	  fi
  
          mount -t ${FILESYS} -o ${OPTIONS} ${PART_DEV} ${MNT}
	    
          if [ $? != 0 ]; then
	    error "can't mount ${PART_DEV} : not a valid filesystem"
	    continue
	  fi

	  PART_DEV=`basename $PART_DEV`

	      if [ "$2" = "hotplug" ]; then
		  add_volume usb ${PART_DEV} usb${HD_NUM}/${PART_NUM} ${PART_FS}
	      else	
		  add_volume hdisk ${PART_DEV} hd${HD_NUM}/${PART_NUM} ${PART_FS}
	      fi

        fi

    done
    
}

HD_NUM=0
scan_storage() {
# $1 = if 'hotplug' then can be a usb key or so

    ROOT_PART="`get_config root | grep -E 'dev.(hd|sd)'`"

	
    # load all kernel modules for supported filesystems
    # refer to SUPPORTED_FS defined in utils.sh
    # all unused modules will be removed at the end of this function
    act "load modules to scan supported filesystems"
    for m in `iterate $SUPPORTED_FS`; do
	  loadmod ${m}
    done

    #######################
    #### scan IDE harddisks
    #######################
    ## not if in hotplug (i presume there aren't /dev/hd* devices)
    if ! [ "$2" = "hotplug" ]; then

    for DEVPATH in `ls /proc/ide | awk '/^hd.*/ {print $1}'`; do

        DEV=`basename ${DEVPATH}`

        # skip if not an harddisk
	if  [ `cat /proc/ide/$DEV/media` != disk ]; then continue; fi

	HD_NUM=`expr $HD_NUM + 1`

	MOUNT_OPTS=""
	MOUNT_FS=""

	if [ "`uname -a | grep xbox`" ]; then
	    MOUNT_FS="-t fatx"
	    MOUNT_OPTS="-o umask=777"
	fi

        notice "scanning harddisk ${DEV}"
        nohdparm="`get_config nohdparm`" # no hdparm optimization settings, comma separated list of devices
        if [ "$nohdparm" ]; then
          for h in `iterate $nohdparm`; do
            if [ "$h" != "${DEV}" ]; then
              act "activating DMA channel and 32bit IO"
              hdparm -d1 -c1 /dev/${DEV}        
            fi
          done
        fi

	# IDE partitions
	scan_partitions ${DEV}

    done

    fi # hotplug

    ########################
    #### scan SCSI harddisks
    ########################

    for DEV in `ls /dev | awk '/^sd.$/ {print $1}'`; do
       # TODO: be sure to detect it's an harddisk
       HD_NUM=`expr $HD_NUM + 1`
       if [ "$1" = "hotplug" ]; then
	   
	   notice "scanning hotplug storage ${DEV}"
	   
	   scan_partitions ${DEV} hotplug

       else

	   notice "scanning storage ${DEV}"
	   
	   scan_partitions ${DEV}

       fi
    done

    # now remove all unused filesystem kernel modules
    act "cleanup unused filesystem modules"
    USEDFS=`mount | awk '{print $5}'`
    for fs in `iterate_backwards $SUPPORTED_FS`; do
      if [ -z "`echo ${USEDFS} | grep ${fs}`" ]; then
        rmmod ${fs} 2>/dev/null 1>/dev/null
      fi
    done
}

scan_removable() {

  act "checking for floppy drivers"
  if ! [ "`dmesg | grep 'no floppy controllers'`" ]; then
      if [ "`dmesg | grep -i 'floppy.*fd0'`" ]; then
	  add_volume floppy fd0 floppy auto
      fi
      if [ "`dmesg | grep -i 'floppy.*fd1'`" ]; then
	  add_volume floppy fd1 floppy auto
      fi
  fi

}




