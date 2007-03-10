# dyne:II startup scripts
# (C) 2005-2007 Denis "jaromil" Rojo
# GNU GPL License

source /lib/dyne/utils.sh

scan_docked_kmods() {

  if   [ "$1" = "hdisk" ]; then

    kmods=`cat /boot/volumes | grep '^hdisk' | grep krn`

  elif [ "$1" = "dvd" ]; then

    kmods=`cat /boot/volumes | grep '^dvd' | grep krn`

  elif [ "$1" = "cdrom" ]; then

    kmods=`cat /boot/volumes | grep '^cdrom' | grep krn`

  else

    return

  fi

  for k in ${(f)kmods}; do

    kpath="`echo ${k} | awk '{print $3}'`/dyne/linux-${KRN}.kmods"

    if ! [ -r $kpath ]; then continue; fi

    if [ "$kmods_found" = "true" ]; then break; fi

    mkdir -p /mnt/.kmods/${KRN}
    mkdir -p /lib/modules/${KRN}

    mount -o loop,ro -t squashfs ${kpath} /mnt/.kmods/${KRN}
    if [ $? = 0 ]; then

      act "kernel modules found in ${kpath}"
      kmods_found=true

    else

      continue

    fi

    # load union filesystem module from inside the squash
    insmod /mnt/.kmods/${KRN}/kernel/fs/unionfs/unionfs.ko
	
    if [ $? = 0 ]; then
	act "overlaying module directory with unionfs"
	mkdir -p /var/cache/union/kmods_rw
	mount -t unionfs -o dirs=/var/cache/union/kmods_rw=rw:/mnt/.kmods/${KRN}=ro unionfs /lib/modules/${KRN}
    else
        error "no unionfs module found, mounting kernel modules read-only"
        umount /mnt/.kmods/${KRN}
        mount -o loop,ro -t squashfs ${kpath} /lib/modules/${KRN}
    fi

  done

}

load_pci_kmods() {

   notice "loading kernel modules for PCI support"

   # FIX es1988 driver (found on a hp omnibook xe3
   # uses the kernel oss maestro3 driver
   # jaromil 26 07 2002
   # if [ ! -z "`lspci| grep 'ESS Technology ES1988 Allegro-1'`" ]; then
   #  loadmod maestro3
   # fi

   # FIX VIA Rhine ethernet cards
   # Ethernet controller: VIA Technologies, Inc.: Unknown device 3065
   # 28 aug 2002 // jaromil
   # if [ ! -z "`lspci|grep 'Ethernet controller: VIA Technologies'`" ]; then
   #   echo "[*] VIA Rhine ethernet card detected"
   #   loadmod via-rhine
   # fi


   ### NOW WITH PCIMODULES

   # 27 maggio 2003 - jaromil e mose'
   # the first thing we want to load are alsa modules
   # btaudio and modem devices should be secondary
   # so we push on top of the list snd-* 
   BOGUS_SOUND="btaudio|8x0m|modem"

   # we exclude the modules that crash some machines
   BAD_MODULES="i810_rng|hw_random|shpchp|pciehp"

   # load alsa modules first
   for i in `pcimodules | sort -r | uniq | grep snd- | grep -ivE "$BOGUS_SOUND"`; do
     loadmod $i
   done

   # then load all other modules (alsa overrides oss this way)
   for i in `pcimodules | sort -r | uniq | grep -v snd- | grep -ivE '$BOGUS_SOUND' | grep -ivE '$BAD_MODULES'`; do
     loadmod $i 
   done

   act "activating low-latency realtime scheduling"
   loadmod realtime

}

