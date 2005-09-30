# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License


# generate volumes entries in the upper right dock of wmaker

# a volume entry is one line:
# hdisk|floppy|cd|usb  /dev/ice  /vol/mountpoint  filesystem  [sys|rem]

rox_gen_volumes() {
    if [ -r /boot/pan_Default ]; then rm /boot/pan_Default; fi

    echo "<?xml version=\"1.0\"?>" > /boot/pan_Default
    echo "<panel side=\"Right\">" >> /boot/pan_Default
    echo "<start>" >> /boot/pan_Default
    echo "<icon label=\"dyne:II\">/usr/bin/dynesplash</icon>" >> /boot/pan_Default

    cat /boot/volumes | awk '
$1 == "hdisk"  {   print "  <icon label=\"HD " NR "\">" $3 "</icon>"     }
$1 == "floppy" {   print "  <icon label=\"Floppy\">" $3 "</icon>"        }
$1 == "usb"    {   print "  <icon label=\"Usb\">" $3 "</icon>"           }
$1 == "cdrom"  {   print "  <icon label=\"CD\">" $3 "</icon>"            }
$1 == "dvd"    {   print "  <icon label=\"DVD " NR "\">" $3 "</icon>"    }
' >> /boot/pan_Default

    echo "</start>" >> /boot/pan_Default
    echo "<end/>" >> /boot/pan_Default
    echo "</panel>" >> /boot/pan_Default

    if [ -r /var/local/pan_Default ]; then
      rm -f /var/local/pan_Default
    fi
    cp /boot/pan_Default /var/local/pan_Default
}

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

    
    if [ -r /var/local/WMState ]; then
	rm -f /var/local/WMState
    fi
    cp /usr/share/dyne/WMState.head /var/local/WMState
    cat /boot/WMState >> /var/local/WMState
    cat /usr/share/dyne/WMState.foot >> /var/local/WMState
}


