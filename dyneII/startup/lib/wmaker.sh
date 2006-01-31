# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License

# this script handles the default procedures for starting x
# choosing a windowmaker, it will generate volumes entries in the dock
# as well application entries for the menu

# a la dyne staila :)

# a volume entry is one line:
# hdisk|floppy|cd|usb  /dev/ice  /vol/mountpoint  filesystem  [sys|rem]

source /lib/dyne/utils.sh

# ROX paths
ROXPDTMP=/var/run/rox_pan_Default
ROXICONSTMP=/var/run/rox_globicons
ROXPD=/etc/xdg/rox.sourceforge.net/ROX-Filer/pan_Default
ROXICONS=/etc/xdg/rox.sourceforge.net/ROX-Filer/globicons

# Window Maker paths
WMSTATETMP=/var/run/WMState
WMSTATEHEAD=/lib/dyne/GNUstep/WMState.head
WMSTATEFOOT=/lib/dyne/GNUstep/WMState.foot
WMSTATE=/lib/dyne/GNUstep/WMState
WMMENU=/lib/dyne/GNUstep/WMRootMenu

# Fluxbox paths
FLXMENU=/etc/fluxbox/menu

check_app_entry() {
# usage:
# check_app_entry  single_line_from_applist  file_to_write
# (used internally for check_apps_present)

     l=$1
     d=$2

     if [ "`echo ${l[1]}`" = "#" ]; then
       continue     # skip comments
     fi

     # pass nesting tags
     if [ "`echo $l | cut -f1 -d'|'`" = "Begin" ]; then
       echo "$l" >> $d
       continue
     fi

     if [ "`echo $l | cut -f1 -d'|'`" = "End" ]; then
       echo "$l" >> $d
       continue
     fi

     # pass special entries
     if [ "$l" = "DESKTOP" ]; then
       echo "$l" >> $d
       continue
     fi

     # and now check the applications
     APP="`echo $l | cut -f3 -d'|' | awk '{print $1}'`"
     which $APP    1>/dev/null     2>/dev/null
     if [ $? = 0 ]; then
       echo "$l" >> $d
     fi

}

check_apps_present() {
# parses /lib/dyne/dyne.applist and checks wich applications are present
# prints out a list of applications present in /boot/dyne.apps

# the order is given by the configuration directive: menu_sections
# it can contain a list of module names

  if [ $1 ]; then
    APPS=$1
  else
    APPS=/boot/dyne.apps
  fi

  if [ -w $APPS ]; then
    rm    $APPS
  fi

  echo "# list of applications detected in the current dyne system" \
       >  $APPS
  echo "# automatically generated at boot" >> /boot/dyne.apps
  echo >> $APPS

  MENU=`get_config menu_sections`
  if [ $MENU ]; then
  for section in `iterate $MENU`; do

    if ! [ -r /opt/$section/applist ]; then
      error "menu section $section requested, but nothing is found in /opt/$section/applist"
      continue
    fi

    LINE=`cat /opt/$section/applist`

    for l in ${(f)LINE}; do
      check_app_entry $l $APPS
    done

  done
  fi

  LINE=`cat /lib/dyne/dyne.applist`
  for l in ${(f)LINE}; do
    check_app_entry $l $APPS
  done

}

fluxbox_gen_menu() {

    mkdir -p /etc/fluxbox

    if [ $1 ]; then
      APPS=$1
    else
      APPS=/boot/dyne.apps
    fi

    if [ ! -r $APPS ]; then
       notice "scanning for applications installed, please wait..."
       check_apps_present $APPS
    fi

    if [ -r $FLXMENU ]; then
       rm $FLXMENU
    fi

    cat $APPS \
    | awk -f /lib/dyne/menugen.awk -v render=fluxbox \
    > $FLXMENU

	# now append the static entries: xutils, desktop, exit
	cat /lib/dyne/menu.fluxbox >> $FLXMENU
	# and close up the menu
	echo "[end]" >> $FLXMENU
}

wmaker_gen_menu() {

    if [ $1 ]; then
      APPS=$1
    else
      APPS=/boot/dyne.apps
    fi

    if [ ! -r $APPS ]; then
       notice "scanning for applications installed, please wait..."
       check_apps_present $APPS
    fi

    if [ -r $WMMENU ]; then
       rm $WMMENU
    fi

    cat /boot/dyne.apps \
    | awk -f /lib/dyne/menugen.awk -v render=wmaker \
    > $WMMENU


	# now append the static entries: xutils, desktop, exit
	cat /lib/dyne/menu.wmaker >> $WMMENU
	# and close up the menu
	echo ")" >> $WMMENU
}


# ROX filer
rox_gen_volumes() {

    act "generating ROX Filer setup"

    if [ -r $ROXPDTMP    ]; then rm $ROXPDTMP; fi
    if [ -r $ROXICONSTMP ]; then rm $ROXICONSTMP;   fi

    # the panel
    cat <<EOF > $ROXPDTMP
<?xml version="1.0"?>
<panel side="Right">
<start>
<icon label="dyne:II">/usr/bin/dynesplash</icon>
EOF

    # the icons
    cat <<EOF > $ROXICONSTMP
<?xml version="1.0"?>
<special-files>
<rule match="/usr/bin/dynesplash">
<icon>/usr/share/dyne/splash/logo-sm.png</icon>
</rule>
<rule match="/usr/bin/gohome">
<icon>/usr/share/icons/graphite/48x48/filesystems/gnome-fs-home.png</icon>
</rule>
EOF


    # panel
    echo $HDISKS | awk '{ print "  <icon label=\"HD " NR "\">/mnt/" $1 "</icon>" }' \
                       >> $ROXPDTMP

    # icons
    echo $HDISKS | awk '{ print "<rule match=\"/mnt/" $1 "\"> <icon>/usr/share/icons/graphite/48x48/filesystems/gnome-fs-blockdev.png</icon> </rule>" }' >> $ROXICONSTMP

    # partitions
    cat /boot/volumes | grep "^hdisk" | awk '{ print "<rule match=\"" $3 "\"> <icon>/usr/share/icons/graphite/48x48/apps/drawer.png</icon> </rule>" }' >> $ROXICONSTMP


    # then all the rest
    # panel
    cat /boot/volumes | grep -v "^hdisk" | awk '
        /^floppy/ {  print "  <icon label=\"Floppy\">" $3 "</icon>" }
        /^usb/    {  print "  <icon label=\"Usb\">" $3 "</icon>"    }
        /^cd/     {  print "  <icon label=\"CD\">" $3 "</icon>"     }
        /^dvd/    {  print "  <icon label=\"DVD\">" $3 "</icon>"    }
        ' >> $ROXPDTMP

    # icons
    cat /boot/volumes | grep -v "^hdisk" | awk '
        /^floppy/ { print "<rule match=\"" $3 "\"><icon>/usr/share/icons/graphite/48x48/devices/gnome-dev-floppy.png</icon></rule>" }
        /^cd/     { print "<rule match=\"" $3 "\"><icon>/usr/share/icons/graphite/48x48/devices/gnome-dev-cdrom.png</icon></rule>" }
        /^dvd/    { print "<rule match=\"" $3 "\"><icon>/usr/share/icons/graphite/48x48/devices/gnome-dev-dvdr.png</icon></rule>" }
        /^usb/    { print "<rule match=\"" $3 "\"><icon>/usr/share/icons/crystalsvg/48x48/devices/usbpendrive_unmount.png</icon></rule>" }
        ' >> $ROXICONSTMP

    # local area network, check IANA assigned private ips:
#    LAN=`ifconfig | awk '/inet addr.*192.168/ { print "true"; exit }
#                         /inet addr.*10./     { print "true"; exit }
#                         /inet addr.*172.16/  { print "true"; exit }'`
    LAN=`lspci | grep -i 'ethernet'`
    if [ $LAN ]; then
      echo "<icon label=\"Lan\">/usr/bin/LinNeighborhood</icon>" >> $ROXPDTMP
      echo "<rule match=\"/usr/bin/LinNeighborhood\"><icon>/usr/share/icons/graphite/48x48/filesystems/gnome-fs-network.png</icon></rule>" >> $ROXICONSTMP
    fi

    # close the panel
    echo "</start>" >> $ROXPDTMP
    echo "<end/>" >> $ROXPDTMP
    echo "</panel>" >> $ROXPDTMP

    # close the icons
    echo "</special-files>" >> $ROXICONSTMP

    cp $ROXPDTMP    $ROXPD
    cp $ROXICONSTMP $ROXICONS
}

# Window Maker
wmaker_gen_volumes() {
    mkdir -p /etc/GNUstep/


    cp $WMSTATEHEAD $WMSTATE

#    if [ -r $WMSTATETMP ]; then rm $WMSTATETMP; fi

    echo $HDISKS | awk '
{
print ","
print "{"
print "Name = \"Hd" NR+1 ".HardDisk\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"rox " $3 "\";"
print "Position = \"0," NR+1 "\";"
print "Forced = no;";
print "BuggyApplication = no;"
print "}"
}
' >> $WMSTATE

cat /boot/volumes | awk '
/^floppy/ {
print ","
print "{"
print "Name = \"Floppy" NR+2 ".FloppyDisk\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"rox " $3 "\";"
print "Position = \"0," NR+2 "\";"
print "Forced = no;"
print "BuggyApplication = no;"
print "}"
}

/^usb/ {
print ","
print "{"
print "Name = \"Usb" NR+2 ".UsbStorage\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"rox " $3 "\";"
print "Position = \"0," NR+2 "\";"
print "Forced = no;"
print "BuggyApplication = no;"
print "}"
}

/^cdrom/ {
print ","
print "{"
print "Name = \"Cd" NR+2 ".CdRom\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"rox " $3 "\";"
print "Position = \"0," NR+2 "\";"
print "Forced = no;"
print "BuggyApplication = no;"
print "}"
}
' >> $WMSTATE

cat $WMSTATEFOOT >> $WMSTATE

}




# this function is called in .xinitrc by default
dyne_startx() {
  # source /etc/LANGUAGE

  # our beloved splashscreen
  if ! [ -r $HOME/.nosplash ]; then
     dynesplash &
  fi

  # this honours configuration directives
  # sent thru kernel parameters and dyne.cfg
  if ! [ $WINDOWMANAGER ]; then # no .xinitrc user setting
    WINDOWMANAGER=`get_config window_manager`
    if ! [ $WINDOWMANAGER ]; then # and no dyne.cfg
      # our default stays WindowMaker
      WINDOWMANAGER=wmaker
    fi
  fi

  # generate the list of harddisks
  HDISKS=`cat /boot/volumes | grep "^hdisk" | awk '{print $3}' | cut -d/ -f3 | uniq`

  # setup the windowmanager
  if [ $WINDOWMANAGER = wmaker ]; then

    wmaker_gen_menu
    wmaker_gen_volumes

    # prepare ROX filer for its first start
    mkdir -p $HOME/.config/rox.sourceforge.net/ROX-Filer

  elif [ $WINDOWMANAGER = fluxbox ]; then

    fluxbox_gen_menu
    rox_gen_volumes

    # start our ROX filer with pinboard and panel
    mkdir -p $HOME/.config/rox.sourceforge.net/ROX-Filer
    (sleep 3; rox -p Default -r Default &)&

  fi

  # turn off the screensaver
  (sleep 1; xset s off -dpms &)&

  # here set the language settings and keyboard mapping
  if [ -r /etc/LANGUAGE ]; then source /etc/LANGUAGE; fi

  if [ $KEYB ]; then
    (sleep 2; /usr/X11R6/bin/setxkbmap $KEYB &)&
  fi

  # start the system resource monitor
  # gkrellm -w -t /usr/share/gkrellm2/Egan &
  # the multiple desktop pager
  (sleep 10; fbpager -w &)&

  # and the window manager
  exec $WINDOWMANAGER
}


