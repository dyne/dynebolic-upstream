# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License

# services and peripherals initialization

source /lib/dyne/utils.sh

init_firewire() {

  if [ "`lsmod | grep 1394`" ]; then
    notice "enabling ieee1394 firewire support"
    loadmod raw1394
    loadmod video1394
    loadmod dv1394
  fi

}

init_pcmcia() {
  if [ "`lspci | grep CardBus`" ]; then
    notice "enabling pcmcia cardbus support"
    loadmod pcmcia
  fi
}

init_modules() {

   notice "loading kernel modules"

   # first apply fixes:

   # FIX es1988 driver (found on a hp omnibook xe3
   # uses the kernel oss maestro3 driver
   # jaromil 26 07 2002
   if [ ! -z "`cat /proc/pci | grep 'ESS Technology ES1988 Allegro-1'`" ]; then
     loadmod maestro3
   fi

   # FIX VIA Rhine ethernet cards
   # Ethernet controller: VIA Technologies, Inc.: Unknown device 3065
   # 28 aug 2002 // jaromil
   if [ ! -z "`lspci|grep 'Ethernet controller: VIA Technologies'`" ]; then
     echo "[*] VIA Rhine ethernet card detected"
     loadmod via-rhine
   fi


   # FIX for nforce onboard audio and ethernet from nvidia
   # those are very popular, expecially on compact EPIA mini-ITX m/b
   # dirty fix by jrml 14 08 2003
   # let's not use the nvidia audio driver,
   # there is an alsa one working better !
   #if [ ! -z "`lspci | grep -i 'multimedia audio' | grep -i ' nvidia'`" ]; then
   #  notice "NForce audio controller found"
   #  loadmod nvaudio
   #fi
   if [ ! -z "`lspci | grep -i 'ethernet' | grep -i ' nvidia'`" ]; then
     notice "NForce ethernet device found"
     loadmod nvnet
   fi

   ### NOW WITH PCIMODULES

   # 27 maggio 2003 - jaromil e mose'
   # the first thing we want to load are alsa modules
   # btaudio and modem devices should be secondary
   # so we push on top of the list snd-* 
   BOGUS_SOUND="btaudio|8x0m|modem"

   # we exclude the modules that crash some machines
   BAD_MODULES="i810_rng"

   # load alsa modules first
   for i in `pcimodules | sort -r | uniq | grep snd- | grep -ivE "$BOGUS_SOUND"`; do
     loadmod $i
   done

   # then load all other modules (alsa overrides oss this way)
   for i in `pcimodules | sort -r | uniq | grep -v snd- | grep -ivE '$BOGUS_SOUND' | grep -ivE '$BAD_MODULES'`; do
     loadmod $i 
   done

   # load ACPI button module for button-driven power down
   if [ -x /proc/acpi ]; then
      act "activating ACPI modules"
      loadmod ac
      loadmod battery
      loadmod button
      loadmod fan
      loadmod processor
      loadmod thermal
      loadmod video
   fi

}

apply_network() {
  # when configuration settings weren't found, set defaults
  if [ -z $NET_IP   ]; then NET_IP="dhcp";            fi
  if [ -z $NET_DEV  ]; then NET_DEV="eth0";           fi
  if [ -z $NET_MASK ]; then NET_MASK="255.255.255.0"; fi
  if [ -z $NET_DNS  ]; then NET_DNS="193.155.207.61"; fi

  # now activate configuration
  if [ $NET_IP = "dhcp" ]; then
    act "scanning for dhcp network configuration"
    /usr/sbin/dhcpcd -d -n &
  else
    act "configuring $NET_DEV network with ip $NET_IP and gateway $NET_GW"
    ifconfig $NET_DEV $NET_IP netmask $NET_MASK
    route add default gw $NET_GW
    append_line /etc/resolv.conf "nameserver $NET_DNS"
  fi

  # setup hostname from /etc/HOSTNAME
  # or randomize with the eth0 MAC address if needed

  # kernel option: hostname
  if ! [ "$HOSTNAME" ]; then
      HOSTNAME="`get_config hostname`"
  fi

  if ! [ "$HOSTNAME" ]; then
      # random hostname generation using first macaddress
      MACADDR="`/sbin/ifconfig eth0 2>/dev/null | grep HWaddr | awk '{print $5}' | sed -e 's/[\:\$]//g' `"
      if [ "$MACADDR" ]; then
        HOSTNAME="dyne-${MACADDR}"
      else
        HOSTNAME="dyne-`cat /etc/DYNEBOLIC`"
      fi
  fi
  
  hostname "$HOSTNAME"
  act "our hostname is `hostname`"
  # setup the hostname in /etc/hosts to resolve it at least in loopback
  append_line /etc/hosts "127.0.0.1\t$HOSTNAME"
}



init_network() {

  notice "initializing network services"

  if [ -r /etc/NETWORK ]; then
    source /etc/NETWORK
  fi

  # network kernel option: comma separated list in this format
  # ip_address,gateway,interface,netmask,dns or just dhcp 
  #                     ^^^^^     ^^^^^   ^
  #                        optional values
  NETWORK="`get_config network`"

  if [ $NETWORK ]; then

    NET_IP=`echo $NETWORK | awk 'BEGIN { FS=","   }
                                       { print $1 }'`

    NET_GW=`echo $NETWORK | awk 'BEGIN { FS=","   }
                                       { print $2 }'`

    NET_DEV=`echo $NETWORK | awk 'BEGIN { FS=","  }
                                        { if($3) print $3
                                          else   print "eth0" }'`

    NET_MASK=`echo $NETWORK | awk 'BEGIN { FS="," }
                                         { if($4) print $4
                                           else   print "255.255.255.0" }'`

    # default DNS here from http://european.nl.orsn.net
    NET_DNS=`echo $NETWORK | awk 'BEGIN { FS="," }
                                        { if($5) print $5
                                          else   print "193.155.207.61" }'`

  fi


  # this applies settings collected so far
  apply_network

 
  # kernel configuration: daemons
  # comma separated list of network services to activate at startup
  # supported values: ssh,ppp,samba,firewall,cups,rsync
  DAEMONS="`get_config daemons`"
  if ! [ $DAEMONS ]; then
    # set defaults
    DAEMONS="samba,cups,tor"
  fi  

  for d in `iterate $DAEMONS`; do
  
    if [ $d = "ssh" ]; then 
      act "starting Secure Shell daemon"
      touch /var/log/lastlog
      /usr/sbin/sshd
    fi
  
    if [ $d = "ppp" ]; then
      act "activating Point to Point protocol"
      loadmod ppp_generic
      loadmod ppp_async
      loadmod ppp_deflate
    fi

    if [ $d = "cups" ]; then
      act "activating the Common Unix Printer Service"
      loadmod parport
      /usr/sbin/cupsd
    fi
  
    if [ $d = "samba" ]; then
      act "activating Samba filesharing"
      if [ -r /boot/dynenv.samba ]; then     rm -f /boot/dynenv.samba; fi
      cat <<EOF > /boot/dynenv.samba
[dyne.dock]
comment = `cat /usr/etc/DYNEBOLIC`
path = ${DYNE_SYS_MNT}
public = yes
read only = yes
encrypt password = yes
smb passwd file = /etc/samba/passwd
EOF
      loadmod smbfs
      smbd
      # we are mostly clients, so we don't start our own name resolution
      # nmbd
    fi
  
    if [ $d = "firewall" ]; then
      act "loading Firewall kernel modules"
      loadmod iptable_filter
      loadmod iptable_nat
      loadmod iptable_mangle
      if [ -x /etc/FIREWALL ]; then
        act "executing firewall script in /etc/FIREWALL"
        sh /etc/FIREWALL
      fi
    fi

    if [ $d = "rsync" ]; then
      act "launching rsync daemon for network install"
      cat <<EOF > /boot/dynenv.rsync
use chroot = true
log file = /var/log/rsync.dyne.log
motd file = /etc/motd
pid file = /var/run/rsync.dyne.pid

[dyne.dock]
comment = `cat /usr/etc/DYNEBOLIC`
uid = 65534
gid = 6
path = ${DYNE_SYS_MNT}
read only = true
EOF
      rsync --daemon --config /boot/dynenv.rsync
    fi

    if [ $d = "tor" ]; then
      act "starting anonymous proxy (tor+privoxy) on localhost:8118"
      tor -f /etc/tor/torrc
      cd /etc/privoxy
      privoxy
      cd -
    fi

  done
  

  # create the directory for network mounted volumes
  mkdir -p         /mnt/shares
  chown root:users /mnt/shares
  chmod ug+rwx     /mnt/shares
  ln -s /usr/apps/Network/LinNeighborhood /mnt/shares/Add_Shares
  ln -s /usr/apps/Network/DyneSsh /mnt/shares/Add_SSH
  
}

init_sound() {

  notice "initializing sound system"
  # check if alsa drivers are loaded
  ISALSA="`lsmod | grep '^snd'`"

  if [ $ISALSA ]; then
    act "activating midi sequencer"
    loadmod snd-seq

    act "activating alsa-oss emulation"
    loadmod snd-pcm-oss
    loadmod snd-mixer-oss
    loadmod snd-seq-oss
  fi

  # for volumes setup see below...
  # it should be called later, after device filesystem is settled.
}

raise_soundcard_volumes() {

    if [ -r /etc/asound.state ]; then

      act "restoring volumes from previous session"
      alsactl restore

    else

      act "setting up default volumes (see 'alsactl' to change them)"
      # here we gotta do yet some more awk shamanism to parse amixer
      controls=`amixer scontrols | awk 'function printctl()
                                        { out=""; for(i=4;i<=NF;i++) {
                                                    if(i>4) out = out " "
                                                    out = out $i
                                                  }
                                          print out }
                                        $4 ~ "Master"    { printctl() }
                                        $4 ~ "PCM"       { printctl() }
                                        $4 ~ "Headphone" { printctl() }
                                        $4 ~ "Capture"   { printctl() }'`
      for ctl in ${(f)controls}; do
        amixer -q sset ${ctl} "77%" unmute
      done

    fi
}

