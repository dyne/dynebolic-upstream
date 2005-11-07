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
   for i in `pcimodules | sort -r | uniq | grep -v snd- | grep -ivE "$BOGUS_SOUND" | grep -ivE "$BAD_MODULES"`; do
     loadmod $i 
   done

}

init_network() {

  notice "initializing network services"

  if [ -e /etc/NETWORK ]; then
    source /etc/NETWORK
  else
    act "scanning for dhcp net configuration"
    /usr/sbin/dhcpcd &
  fi

# setup hostname from /etc/HOSTNAME or randomize with the eth0 MAC address if needed
if [ -e /etc/HOSTNAME ]; then
    HOSTNAME="`cat /etc/HOSTNAME`"
else
    # random hostname generation using first macaddress
    MACADDR="`/sbin/ifconfig eth0 2>/dev/null \
              | grep HWaddr \
              | cut -d ' '  -f11 \
              | sed -e 's/[\:\$]//g'`"
    if [ $MACADDR ]; then
      HOSTNAME="dyne-${MACADDR}"
    else
      HOSTNAME="dyne"
    fi
    echo "$HOSTNAME" > /etc/HOSTNAME
fi

hostname "$HOSTNAME"
act "our hostname is `hostname`"

# setup the hostname in /etc/hosts to resolve it at least in loopback
if ! [ "`grep $HOSTNAME /etc/hosts`" ]; then
  append_line /etc/hosts "127.0.0.1\t$HOSTNAME"
fi

act "activating point to point protocol"
loadmod ppp_generic
loadmod ppp_async
loadmod ppp_deflate

act "starting secure shell daemon"
/usr/sbin/sshd

#notice "loading iptables nat and masquerading kernel modules"
#loadmod iptable_filter
#loadmod iptable_nat
#loadmod iptable_mangle

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

}
