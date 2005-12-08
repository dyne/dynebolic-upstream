# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License


# generate volumes entries in the upper right dock

# a volume entry is one line:
# hdisk|floppy|cd|usb  /dev/ice  /vol/mountpoint  filesystem  [sys|rem]

source /lib/dyne/utils.sh

dyne_startx() {
  # TODO here  language settings
  # source /etc/LANGUAGE

  # turn off the screensaver
  (sleep 1; xset s off -dpms &)&

  # set the keyboard mapping
  if [ $KEYB ]; then
    (sleep 2; /usr/X11R6/bin/setxkbmap $KEYB &)&
  fi

  # start the system resource monitor
  # gkrellm -w -t /usr/share/gkrellm2/Egan &

  # out beloved splashscreen
  dynesplash &

  # start our ROX filer with pinboard and panel
  mkdir -p $HOME/.config/rox.sourceforge.net/ROX-Filer
  (sleep 3; rox -p Default -r Default &)&

  # the multiple desktop pager
  (sleep 4; fbpager -w &)&

  # and the window manager
  fluxbox
  # wmaker
}

check_apps_present() {
# parses /lib/dyne/dyne.applist and checks wich applications are present
# prints out a list of applications present in /boot/dyne.apps

  LINE=`cat /lib/dyne/dyne.applist`

  if [ -w /boot/dyne.apps ]; then
    rm    /boot/dyne.apps
  fi

  echo "# list applications detected in the current dyne system" \
       >  /boot/dyne.apps
  echo "# automatically generated at boot" >> /boot/dyne.apps
  echo >> /boot/dyne.apps

  for l in ${(f)LINE}; do

     if [ "`echo ${l[1]}`" = "#" ]; then
       continue     # skip comments
     fi

     # pass nesting tags
     if [ "`echo $l | cut -f1 -d'|'`" = "Begin" ]; then
       echo "$l" >> /boot/dyne.apps
       continue
     fi

     if [ "`echo $l | cut -f1 -d'|'`" = "End" ]; then
       echo "$l" >> /boot/dyne.apps
       continue
     fi

     # and now check the applications
     APP="`echo $l | cut -f3 -d'|' | awk '{print $1}'`"  
     which $APP    1>/dev/null     2>/dev/null
     if [ $? = 0 ]; then
       echo "$l" >> /boot/dyne.apps
     fi

  done
}

fluxbox_gen_menu() {

    if [ ! -r /boot/dyne.apps ]; then
       error "can't generate fluxbox menu: dyne.applist not checked"
       error "run check_apps_present to generate /boot/dyne.apps"
       return
    fi

    if [ -r /etc/fluxbox/menu ]; then
       rm /etc/fluxbox/menu
    fi

    cat /boot/dyne.apps \
    | awk -f /lib/dyne/menugen.awk -v render=fluxbox \
    > /etc/fluxbox/menu

}

# ROX filer
rox_gen_volumes() {

    act "generating ROX Filer setup"

    if [ -r /boot/pan_Default ]; then rm /boot/pan_Default; fi
    if [ -r /boot/globicons   ]; then rm /boot/globicons;   fi

    # the panel
    cat <<EOF > /boot/pan_Default
<?xml version="1.0"?>
<panel side="Right">
<start>
<icon label="dyne:II">/usr/bin/dynesplash</icon>
EOF

    # the icons
    cat <<EOF > /boot/globicons
<?xml version="1.0"?>
<special-files>
<rule match="/usr/bin/dynesplash">
<icon>/usr/share/dyne/splash/logo-sm.png</icon>
</rule>
<rule match="/usr/bin/gohome">
<icon>/usr/share/icons/graphite/48x48/filesystems/gnome-fs-home.png</icon>
</rule>
EOF


    # first generate the harddisks
    HDISKS=`cat /boot/volumes | grep "^hdisk" | awk '{print $3}' | cut -d/ -f3 | uniq`

    # panel
    echo $HDISKS | awk '{ print "  <icon label=\"HD " NR "\">/mnt/" $1 "</icon>" }' \
                       >> /boot/pan_Default

    # icons
    echo $HDISKS | awk '{ print "<rule match=\"/mnt/" $1 "\"> <icon>/usr/share/icons/graphite/48x48/filesystems/gnome-fs-blockdev.png</icon> </rule>" }' >> /boot/globicons

    # partitions
    cat /boot/volumes | grep "^hdisk" | awk '{ print "<rule match=\"" $3 "\"> <icon>/usr/share/icons/graphite/48x48/apps/drawer.png</icon> </rule>" }' >> /boot/globicons


    # then all the rest
    # panel
    cat /boot/volumes | grep -v "^hdisk" | awk '
        /^floppy/ {  print "  <icon label=\"Floppy\">" $3 "</icon>" }
        /^usb/    {  print "  <icon label=\"Usb\">" $3 "</icon>"    }
        /^cd/     {  print "  <icon label=\"CD\">" $3 "</icon>"     }
        /^dvd/    {  print "  <icon label=\"DVD\">" $3 "</icon>"    }
        ' >> /boot/pan_Default

    # icons
    cat /boot/volumes | grep -v "^hdisk" | awk '
        /^floppy/ { print "<rule match=\"" $3 "\"><icon>/usr/share/icons/graphite/48x48/devices/gnome-dev-floppy.png</icon></rule>" }
        /^cd/     { print "<rule match=\"" $3 "\"><icon>/usr/share/icons/graphite/48x48/devices/gnome-dev-cdrom.png</icon></rule>" }
        /^dvd/    { print "<rule match=\"" $3 "\"><icon>/usr/share/icons/graphite/48x48/devices/gnome-dev-dvdr.png</icon></rule>" }
        /^usb/    { print "<rule match=\"" $3 "\"><icon>/usr/share/icons/crystalsvg/48x48/devices/usbpendrive_unmount.png</icon></rule>" }
        ' >> /boot/globicons

    # local area network, check IANA assigned private ips:
    LAN=`ifconfig | awk '/inet addr.*192.168/ { print "true"; exit }
                         /inet addr.*10./     { print "true"; exit }
                         /inet addr.*172.16/  { print "true"; exit }'`
    if [ "$LAN" = "true" ]; then
      echo "<icon label=\"Lan\">/usr/bin/smb4k</icon>" >> /boot/pan_Default
      echo "<rule match=\"/usr/bin/smb4k\"><icon>/usr/share/icons/graphite/48x48/filesystems/gnome-fs-network.png</icon></rule>" >> /boot/globicons
    fi
    
    # close the panel
    echo "</start>" >> /boot/pan_Default
    echo "<end/>" >> /boot/pan_Default
    echo "</panel>" >> /boot/pan_Default

    # close the icons
    echo "</special-files>" >> /boot/globicons

    cp /boot/pan_Default \
	/etc/xdg/rox.sourceforge.net/ROX-Filer/pan_Default
    cp /boot/globicons \
	/etc/xdg/rox.sourceforge.net/ROX-Filer/globicons
}

# Window Maker
wmaker_gen_volumes() {

    if [ -r /boot/WMState ]; then rm /boot/WMState; fi
    
    cat /boot/volumes | awk '
$1 == "hdisk" {
print ","
print "{"
print "Name = \"Hd" NR+2 ".HardDisk\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"xfe " $3 "\";"
print "Position = \"0," NR+2 "\";"
print "Forced = no;";
print "BuggyApplication = no;"
print "}"
}

"floppy" == $1 {
print ","
print "{"
print "Name = \"Floppy" NR+2 ".FloppyDisk\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"xfe " $3 "\";"
print "Position = \"0," NR+2 "\";"
print "Forced = no;"
print "BuggyApplication = no;"
print "}"
}

"usb" == $1 {
print ","
print "{"
print "Name = \"Usb" NR+2 ".UsbStorage\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"xfe " $3 "\";"
print "Position = \"0," NR+2 "\";"
print "Forced = no;"
print "BuggyApplication = no;"
print "}"
}

"cdrom" == $1 {
print ","
print "{"
print "Name = \"Cd" NR+2 ".CdRom\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"xfe " $3 "\";"
print "Position = \"0," NR+2 "\";"
print "Forced = no;"
print "BuggyApplication = no;"
print "}"
}
' > /boot/WMState
    
    cp /usr/share/dyne/WMState.head /etc/skel/GNUstep/Defaults/WMState
    cat /boot/WMState >> /etc/skel/GNUstep/Defaults/WMState
    cat /usr/share/dyne/WMState.foot >> /etc/skel/GNUstep/Defaults/WMState

}

