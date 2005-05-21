# generate volumes entries in the upper right dock of wmaker

# a volume entry is one line:
# hdisk|floppy|cd|usb  /dev/ice  /vol/mountpoint  filesystem  [sys|rem]

wmaker_gen_volumes() {

    if [ -r /boot/WMState ]; then rm /boot/WMState; fi
    
    cat /boot/volumes | awk '
$1 == "hdisk" {
print ","
print "{"
print "Name = \"Hd" NR+2 ".HardDisk\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"xwc " $3 "\";"
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
print "Command = \"xwc " $3 "\";"
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
print "Command = \"xwc " $3 "\";"
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
print "Command = \"xwc " $3 "\";"
print "Position = \"0," NR+2 "\";"
print "Forced = no;"
print "BuggyApplication = no;"
print "}"
}
' > /boot/WMState

    
    if [ -r /home/GNUstep/Defaults/WMState ]; then
	rm -f /home/GNUstep/Defaults/WMState
    fi
    cp /usr/share/dynebolic/templates/WMState.head /home/GNUstep/Defaults/WMState
    cat /boot/WMState >> /home/GNUstep/Defaults/WMState
    cat /usr/share/dynebolic/templates/WMState.foot >> /home/GNUstep/Defaults/WMState
    
    act "WindowMaker configured"
}


