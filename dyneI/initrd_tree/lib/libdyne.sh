#!/bin/sh
#
# miscellaneous procedures called by dyne:bolic initialization scripts
#
#  * Copyright (C) 2003 Denis Rojo aka jaromil <jaromil@dyne.org>
#  * and Alex Gnoli aka smilzo <smilzo@sfrajone.org>
#  * freely distributed in dyne:bolic GNU/Linux http://dynebolic.org
#  * 
#  * This source code is free software; you can redistribute it and/or
#  * modify it under the terms of the GNU Public License as published 
#  * by the Free Software Foundation; either version 2 of the License,
#  * or (at your option) any later version.
#  *
#  * This source code is distributed in the hope that it will be useful,
#  * but WITHOUT ANY WARRANTY; without even the implied warranty of
#  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#  * Please refer to the GNU Public License for more details.
#  *
#  * You should have received a copy of the GNU Public License along with
#  * this source code; if not, write to:
#  * Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#  *
#  * "Header: $"


# by jaromil & smilzo - 6 july 2003

DYNEBOL_NST="dynebol.nst"
DYNEBOL_CFG="dynebol.cfg"

# wmaker dock stuff
if [ -e /boot/wmdock-pos ]; then
    WMPOS="`cat /boot/wmdock-pos`";
else
    WMPOS=0;
fi
WMCFG="/boot/WMState"

dyne_mount_nest() {
  # $1 = full path to dyne:bolic nest configuration (dynebol.cfg)
  # returns 1 on failure, 0 on success
  if [ ! -e $1 ]; then return; fi
  if [ -e /boot/nest ]; then
    echo "[!] another nest found on $1"
    echo " .  it overlaps an allready mounted nest, skipped!"
    return 1
  fi
  echo "[*] activating dyne:bolic nest in $1"
  source $1
  # TODO : controllare che il file di conf abbia tutto apposto
  if [ ! -z $DYNEBOL_ENCRYPT ]; then
    clear
    cat <<EOF




*******************************************************************************
An $DYNEBOL_ENCRYPT encrypted nest
has been detected in $DYNEBOL_NST
access is password restricted, please supply your passphrase now

EOF
    mount -o loop,encryption=$DYNEBOL_ENCRYPT $DYNEBOL_NEST /mnt/nest
    if [ $? != 0 ]; then
      echo
      echo "Invalid password or corrupted file"
    fi
  else
    mount -o loop $DYNEBOL_NEST /mnt/nest
  fi
  
  if [ $? != 0 ]; then 
    echo "[!] can't mount nest, skipping"
    # ce ne andiamo senza togliere le variabili di ambiente
    # il che le rende inaffidabili per detctare la presenza di un nido montato
    # USARE /boot/nest per quello!
    return 1
  fi
  
  echo " .  nest succesfully mounted"

  # ok, success! we mount the nest
  sync
  
  if [ -e /mnt/nest/etc ]; then
    cp /etc/fstab /boot
    cp /etc/auto.removable /boot
    # qui c'e' un problema concettuale dice lo smilzo :)
    # in effetti si monta bindata una etc sopra l'altra
    # ma il mount in questo modo non puo' aggiornare correttamente mtab
    # quindi ecco la soluzione (jrml 21 jul 03)
    cp /etc/mtab /boot
    echo "/mnt/nest/etc /etc none rw,bind 0 0" >> /boot/mtab
 
    mount -o bind /mnt/nest/etc /etc
    mv /boot/fstab /etc
    mv /boot/auto.removable /etc
    mv /boot/mtab /etc 
    echo " .  nested /etc directory bind"
  else
    echo "[!] nest is missing /etc directory"
    echo " .  fix nest by populating etc"
    cp -a /etc /mnt/nest
    mount -o bind /mnt/nest/etc /etc
  fi 

  sync

#  if [ ! -z "`mount | grep home`" ]; then
#      umount /home; fi
  if [ ! -e /mnt/nest/home ]; then
    echo "[!] nest is missing /home directory"
    echo " .  fix nest by populating home"
    tar xfz /mnt/dynebolic/home.tgz -C /mnt/nest
  fi
  mount -o bind /mnt/nest/home /home
  echo " .  nested /home directory bind"

  if [ ! -e /mnt/nest/var ]; then
    echo "[!] nest is missing /var directory"
    echo " .  fix nest by populating var"
    tar xfz /mnt/dynebolic/var.tgz -C /mnt/nest
  fi 
  mount -o bind /mnt/nest/var /var
  echo " .  nested /var directory bind"

  if [ ! -e /mnt/nest/tmp ]; then
    echo "[!] nest is missing /tmp directory"
    echo " .  fix nest by creating tmp"
    mkdir /mnt/nest/tmp
  fi 
  mount -o bind /mnt/nest/tmp /tmp
  echo " .  nested /tmp directory bind"

  echo "$1" > /boot/nest
  echo " .  nest activated"
  return 0
}

dyne_add_volume() {
  # $1 = media type (hdisk|floppy|usbkey)
  # $2 = mount point
  echo "[*] adding new $1 volume $2"
  case "$1" in
      "hdisk")
	  echo "," >> $WMCFG;
	  echo "{" >> $WMCFG;
	  echo "Name = \"$HDEV.HardDisk\";" >>$WMCFG;
	  echo "Lock = yes;" >>$WMCFG;
	  echo "Autolaunch = no;" >>$WMCFG;
	  echo "Command = \"xwc /vol/${2}\";" >>$WMCFG;
	  WMPOS="`expr $WMPOS + 1`"
	  echo "Position = \"0,${WMPOS}\";" >>$WMCFG;
	  echo "Forced = no;" >>$WMCFG;
	  echo "BuggyApplication = no;" >>$WMCFG;
	  echo "}" >>$WMCFG;
	  ;;
      "floppy")
	  echo "," >>$WMCFG;
	  echo "{" >> $WMCFG;
	  echo "Name = \"${2}.FloppyDisk\";" >>$WMCFG
	  echo "Lock = yes;" >>$WMCFG
	  echo "Autolaunch = no;" >>$WMCFG
	  echo "Command = \"xwc /rem/${2}\";" >>$WMCFG
	  WMPOS="`expr $WMPOS + 1`"
	  echo "Position = \"0,${WMPOS}\";" >>$WMCFG;
	  echo "Forced = no;" >>$WMCFG;
	  echo "BuggyApplication = no;" >>$WMCFG;
	  echo "}" >>$WMCFG;
	  ;;
      "usb")
	  echo "," >>$WMCFG;
	  echo "{" >> $WMCFG;
	  echo "Name = \"${2}.UsbStorage\";" >>$WMCFG
	  echo "Lock = yes;" >>$WMCFG
	  echo "Autolaunch = no;" >>$WMCFG
	  echo "Command = \"xwc /rem/${2}\";" >>$WMCFG
	  WMPOS="`expr $WMPOS + 1`"
	  echo "Position = \"0,${WMPOS}\";" >>$WMCFG;
	  echo "Forced = no;" >>$WMCFG;
	  echo "BuggyApplication = no;" >>$WMCFG;
	  echo "}" >>$WMCFG;
	  ;;
      "cd")
	  echo "," >>$WMCFG;
	  echo "{" >> $WMCFG;
	  echo "Name = \"${2}.CdRom\";" >>$WMCFG
	  echo "Lock = yes;" >>$WMCFG
	  echo "Autolaunch = no;" >>$WMCFG
	  echo "Command = \"xwc /rem/${2}\";" >>$WMCFG
	  WMPOS="`expr $WMPOS + 1`"
	  echo "Position = \"0,${WMPOS}\";" >>$WMCFG;
	  echo "Forced = no;" >>$WMCFG;
	  echo "BuggyApplication = no;" >>$WMCFG;
	  echo "}" >>$WMCFG;
	  ;;

      *)
	  echo "[!] invalid call to dyne_gen_wmaker_dock() in libdyne.sh"
	  return 0
	  ;;
  esac

  rm -f $WMPOS
  echo "$WMPOS" > /boot/wmdock-pos

}

