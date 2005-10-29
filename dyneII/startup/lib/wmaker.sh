# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License


# generate volumes entries in the upper right dock

# a volume entry is one line:
# hdisk|floppy|cd|usb  /dev/ice  /vol/mountpoint  filesystem  [sys|rem]

source /lib/dyne/utils.sh

# ROX filer
rox_gen_volumes() {

    act "generating ROX Filer setup"

    if [ -r /boot/pan_Default ]; then rm /boot/pan_Default; fi
    if [ -r /boot/globicons   ]; then rm /boot/globicons;   fi

    # the panel
    echo "<?xml version=\"1.0\"?>" > /boot/pan_Default
    echo "<panel side=\"Right\">" >> /boot/pan_Default
    echo "<start>" >> /boot/pan_Default
    echo "<icon label=\"dyne:II\">/usr/bin/dynesplash</icon>" >> /boot/pan_Default

    # the icons
    echo "<?xml version=\"1.0\"?>" > /boot/globicons
    echo "<special-files>"      >> /boot/globicons
    echo "<rule match=\"/usr/bin/dynesplash\"><icon>/usr/share/dyne/splash/logo-sm.png</icon></rule>" >> /boot/globicons

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
        ' >> /boot/globicons
    
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

