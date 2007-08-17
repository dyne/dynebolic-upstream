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
WMSTATETMP=/tmp/WMState
WMSTATEDOCK=/var/run/WMState.dock
WMSTATE=/etc/WindowMaker/WMState
WMMENU=/etc/WindowMaker/WMRootMenu

# Fluxbox paths
FLXMENU=/etc/fluxbox/menu

# Xfce paths
XFCEMENU=/etc/xdg/xfce4/desktop/menu.xml
XFCEPANEL=/etc/xdg/xfce4/panel   # note this is a directory


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

  # load common environment
  source /lib/dyne/zsh/common
  # load dyne modules paths
  source /boot/dynenv.modules

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

  LINE=`cat /lib/dyne/dyne.applist`
  for l in ${(f)LINE}; do
    check_app_entry $l $APPS
  done

  # if modules contain etc/applist then process it
  # this way modules can provide their own description for applications
  # and have a separated menu entry for them.
  for mod in `ls /opt`; do
    if [ -r /opt/$mod/etc/applist ]; then
      LINE=`cat /opt/$mod/etc/applist`
      for l in ${(f)LINE}; do
        check_app_entry $l $APPS
      done
    fi
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

    # here overwrites previous or user defined menu
    #if [ -r /root/GNUstep/Defaults/WMRootMenu ]; then
    #   rm /root/GNUstep/Defaults/WMRootMenu
    #fi
    #cp $WMMENU /root/GNUstep/Defaults/WMRootMenu
    #for u in `ls /home`; do
    #   if [ -r /home/$u/GNUstep/Defaults/WMRootMenu ]; then
    #      rm /home/$u/GNUstep/Defaults/WMRootMenu
    #   fi
    #   cp $WMMENU /home/$u/GNUstep/Defaults/WMRootMenu
    #done

}


# ROX filer
rox_gen_volumes() {

    act "generating ROX Filer setup"

    if [ -r $ROXPDTMP    ]; then rm $ROXPDTMP; fi
    if [ -r $ROXICONSTMP ]; then rm $ROXICONSTMP;   fi

    # generate the list of harddisks
    HDISKS=`cat /boot/volumes | grep "^hdisk" | awk '{print $3}' | cut -d/ -f3 | uniq`


    # the panel
    cat <<EOF > $ROXPDTMP
<?xml version="1.0"?>
<panel side="Right">
<start>
<icon label="dyne:II">/bin/dynesplash</icon>
EOF

    # the icons
    cat <<EOF > $ROXICONSTMP
<?xml version="1.0"?>
<special-files>
<rule match="/bin/dynesplash"> <icon>/usr/share/dyne/splash/logo-sm.png</icon> </rule>
<rule match="/bin/gohome"> <icon>/usr/share/icons/graphite/48x48/filesystems/gnome-fs-home.png</icon> </rule>
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
        /^cd/     {  print "  <icon label=\"CD\">" $3 "</icon>"     }
        /^dvd/    {  print "  <icon label=\"DVD\">" $3 "</icon>"    }
        ' >> $ROXPDTMP
        # usb is now automounted so these lines are removed
        #/^usb/    {  print "  <icon label=\"Usb\">" $3 "</icon>"    }

    # icons
    cat /boot/volumes | grep -v "^hdisk" | awk '
        /^floppy/ { print "<rule match=\"" $3 "\"><icon>/usr/share/icons/graphite/48x48/devices/gnome-dev-floppy.png</icon></rule>" }
        /^cd/     { print "<rule match=\"" $3 "\"><icon>/usr/share/icons/graphite/48x48/devices/gnome-dev-cdrom.png</icon></rule>" }
        /^dvd/    { print "<rule match=\"" $3 "\"><icon>/usr/share/icons/graphite/48x48/devices/gnome-dev-dvdr.png</icon></rule>" }
        ' >> $ROXICONSTMP
        #/^usb/    { print "<rule match=\"" $3 "\"><icon>/usr/share/icons/crystalsvg/48x48/devices/usbpendrive_unmount.png</icon></rule>" }

    # local area network, check IANA assigned private ips:
#    LAN=`ifconfig | awk '/inet addr.*192.168/ { print "true"; exit }
#                         /inet addr.*10./     { print "true"; exit }
#                         /inet addr.*172.16/  { print "true"; exit }'`
    LAN=`lspci | grep -i 'ethernet'`
    if [ $LAN ]; then
      echo "<icon label=\"Lan\">/usr/bin/LinNeighborhood</icon>" >> $ROXPDTMP
      echo "<rule match=\"/usr/bin/LinNeighborhood\"><icon>/usr/share/icons/graphite/48x48/filesystems/gnome-fs-network.png</icon></rule>" >> $ROXICONSTMP
      echo "<rule match=\"/mnt/shares\"><icon>/usr/share/icons/graphite/48x48/filesystems/gnome-fs-network.png</icon></rule>" >> $ROXICONSTMP
    fi

    # add some more icons for the filesystem
    cat <<EOF >> $ROXICONSTMP
<rule match="/home"><icon>/usr/share/icons/graphite/48x48/stock/generic/stock_home.png</icon></rule>
<rule match="/root"><icon>/usr/share/icons/graphite/48x48/stock/generic/stock_home.png</icon></rule>
<rule match="/bin"><icon>/usr/share/icons/graphite/48x48/apps/gnome-run.png</icon></rule>
<rule match="/sbin"><icon>/usr/share/icons/graphite/48x48/apps/gnome-run.png</icon></rule>
<rule match="/lib"><icon>/usr/share/icons/graphite/48x48/apps/gnome-run.png</icon></rule>
<rule match="/usr"><icon>/usr/share/icons/graphite/48x48/apps/gnome-run.png</icon></rule>
<rule match="/opt"><icon>/usr/share/dyne/logo.png</icon></rule>
<rule match="/usr/share"><icon>/usr/share/icons/graphite/48x48/apps/gnome-other.png</icon></rule>
<rule match="/usr/sbin"><icon>/usr/share/icons/graphite/48x48/apps/gnome-run.png</icon></rule>
<rule match="/usr/bin"><icon>/usr/share/icons/graphite/48x48/apps/gnome-run.png</icon></rule>
<rule match="/usr/lib"><icon>/usr/share/icons/graphite/48x48/apps/gnome-run.png</icon></rule>
<rule match="/usr/doc"><icon>/usr/share/icons/graphite/48x48/stock/generic/stock_example.png</icon></rule>
<rule match="/etc"><icon>/usr/share/icons/graphite/48x48/apps/gnome-settings.png</icon></rule>
<rule match="/dev"><icon>/usr/share/icons/graphite/48x48/apps/hwbrowser.png</icon></rule>
<rule match="/sys"><icon>/usr/share/icons/graphite/48x48/apps/hwbrowser.png</icon></rule>
<rule match="/proc"><icon>/usr/share/icons/graphite/48x48/apps/hwbrowser.png</icon></rule>
<rule match="/boot"><icon>/usr/share/icons/graphite/48x48/apps/hwbrowser.png</icon></rule>
<rule match="/var"><icon>/usr/share/icons/graphite/48x48/apps/hwbrowser.png</icon></rule>
EOF
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
# this functions generates the right hand dock for wmaker

    if [ -r $WMSTATEDOCK ]; then return; fi

    # generate the list of harddisks
    HDISKS=`cat /boot/volumes | grep "^hdisk" | awk '{print $3}' | cut -d/ -f3 | uniq`


    # put the header
    cat <<EOF > $WMSTATEDOCK
  Dock = {
    Lowered = Yes;
    Position = "-64,0";
    Applications = (
      {
        Name = Dyne;
        Lock = Yes;
        AutoLaunch = Yes;
        Command = dynesplash;
        Position = "0,0";
        Forced = No;
        BuggyApplication = No;
      },
      {
        Name = Home;
        Lock = Yes;
        AutoLaunch = No;
        Command = "rox";
        Position = "0,1";
        Forced = No;
        BuggyApplication = No;
      }
EOF

    echo $HDISKS | awk '
{
print ","
print "{"
print "Name = \"Hd" NR ".HardDisk\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"rox /mnt/" $1 "\";"
print "Position = \"0," NR+1 "\";"
print "Forced = no;";
print "BuggyApplication = no;"
print "}"
}
' >> $WMSTATEDOCK

    POS=`echo $HDISKS | wc -l` # how many harddisks are up there?
    POS=`expr $POS + 2` # get on the next position in dock

    LAN=`lspci | grep -i 'ethernet'`
    if [ $LAN ]; then
       cat <<EOF >>$WMSTATEDOCK
,
{
Name = "Samba.Network";
Lock = yes;
Autolaunch = no;
Command = "rox /mnt/shares";
Position = "0,$POS";
Forced = no;
BuggyApplication = no;
}
EOF
#      POS=`expr $POS + 1` # advance a position in dock
    fi


cat /boot/volumes | grep -v '^hdisk' | awk -v pos=$POS '
/^floppy/ {
print ","
print "{"
print "Name = \"Floppy" NR ".FloppyDisk\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"rox " $3 "\";"
print "Position = \"0," NR+pos "\";"
print "Forced = no;"
print "BuggyApplication = no;"
print "}"
}

/^usb/ {
print ","
print "{"
print "Name = \"Usb" NR ".UsbStorage\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"rox " $3 "\";"
print "Position = \"0," NR+pos "\";"
print "Forced = no;"
print "BuggyApplication = no;"
print "}"
}

/^cdrom/ {
print ","
print "{"
print "Name = \"Cd" NR ".CdRom\";"
print "Lock = yes;"
print "Autolaunch = no;"
print "Command = \"rox " $3 "\";"
print "Position = \"0," NR+pos "\";"
print "Forced = no;"
print "BuggyApplication = no;"
print "}"
}
' >> $WMSTATEDOCK

    echo "    );" >> $WMSTATEDOCK # close Applications = (
    echo "  };"   >> $WMSTATEDOCK # close Dock = {

    if [ -r $WMSTATE ]; then # WMState is already present
      # we are in a nest, so here we need to substitute only the Dock = { }; section
      # and leave all the rest intact (Clip, Workspaces)
      act "updating existing windowmaker dock"

      # Warning: this currently assumes that the Dock block is at beginning of WMState
      cat $WMSTATE | awk '
           /Dock = {/ { dockstart=NR }
                      { if(!dockstart) print $0 }' > $WMSTATETMP

      cat $WMSTATEDOCK                            >> $WMSTATETMP

      cat $WMSTATE | awk '
           /};/       { dockend=NR; next }
                      { if(dockend) print $0 }'   >> $WMSTATETMP

      cp -f $WMSTATETMP $WMSTATE
      rm -f $WMSTATETMP

      # overwrite docks in nest with the fresh one
      mkdir -p /root/GNUstep/Defaults
      cp -f $WMSTATE /root/GNUstep/Defaults/WMState
      for u in `ls /home`; do
        mkdir -p /home/${u}/GNUstep/Defaults
        cp -f $WMSTATE /home/${u}/GNUstep/Defaults/WMState
      done

    else

      # this is a freshly generated WMState, add other default sections
      act "generating a fresh windowmaker dock"
      echo "{" > $WMSTATE

      cat $WMSTATEDOCK >> $WMSTATE

      cat <<EOF >> $WMSTATE
  Workspace = "DESK 1";
  Workspaces = (
    {
      Name = "DESK 1";
    },
    {
      Name = "DESK 2";
    },
    {
      Name = "DESK 3";
    },
    {
      Name = "DESK 4";
    },
    {
      Name = "DESK 5";
    },
    {
      Name = "DESK 6";
    }
  );
  Applications = ();
}
EOF

    fi
}

xfce_gen_menu() {

    if [ -r $XFCEMENU ]; then
	rm $XFCEMENU
    fi

    # print the header in the new menu.xml
    cat <<EOF > ${XFCEMENU}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xfdesktop-menu>
<!-- automatically generated menu by dyne:bolic startup -->
<xfdesktop-menu>
<title name="Software Menu" icon="/usr/share/dyne/logo-icon.png"/>
<separator/>
<app name="Web Browser" cmd="xfbrowser4" icon="stock_internet"/>
<app name="File Search" cmd="searchmonkey" icon="gnome-searchtool"/>
<app name="Terminal" cmd="launchterm" icon="gnome-terminal"/>

<separator/>
EOF

    cat /boot/dyne.apps \
	| awk -f /lib/dyne/menugen.awk -v render=xfce \
	>> ${XFCEMENU}

    cat <<EOF >> ${XFCEMENU}
<builtin name="Quit" cmd="quit" icon="gnome-logout"/>
</xfdesktop-menu>
EOF

}

xfce_gen_volumes() {
    
    if [ -r $XFCEPANEL/panels.xml ]; then
	rm $XFCEPANEL/panels.xml
    fi
    
    cat <<EOF > $XFCEPANEL/panels.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE config SYSTEM "config.dtd">
<panels>
	<panel>
		<properties>
			<property name="size" value="26"/>
			<property name="monitor" value="0"/>
			<property name="screen-position" value="11"/>
			<property name="fullwidth" value="1"/>
			<property name="xoffset" value="0"/>
			<property name="yoffset" value="741"/>
			<property name="handlestyle" value="0"/>
			<property name="autohide" value="0"/>
			<property name="transparency" value="20"/>
			<property name="activetrans" value="1"/>
		</properties>
		<items>
			<item name="showdesktop" id="1"/>
			<item name="pager" id="2"/>
			<item name="tasklist" id="3"/>
			<item name="systray" id="4"/>
		</items>
	</panel>
	<panel>
		<properties>
			<property name="size" value="36"/>
			<property name="monitor" value="0"/>
			<property name="screen-position" value="7"/>
			<property name="fullwidth" value="0"/>
			<property name="xoffset" value="981"/>
			<property name="yoffset" value="0"/>
			<property name="handlestyle" value="0"/>
			<property name="autohide" value="0"/>
			<property name="transparency" value="20"/>
			<property name="activetrans" value="1"/>
		</properties>
                <items>
			<item name="xfce4-menu" id="5"/>
			<item name="separator" id="6"/>
			<item name="launcher" id="7"/>
EOF

    ################################# HOME / NEST
    rm -f $XFCEPANEL/launcher-7.rc
    cat <<EOF > $XFCEPANEL/launcher-7.rc
[Entry 0]
Name=Home
Exec=gohome
Terminal=false
StartupNotify=false
EOF
    
    mount | grep '/mnt/nest/home on /home' > /dev/null
    if [ $? = 0 ]; then # there is a nest

	if [ -r /dev/mapper/dyne.nst ]; then # is encrypted

	    echo "Comment=Nested home fortified with encryption" >> $XFCEPANEL/launcher-7.rc
	    echo "Icon=/usr/share/icons/tower.png" >> $XFCEPANEL/launcher-7.rc

	else # is not encrypted

	    echo "Comment=Nested home, not encrypted" >> $XFCEPANEL/launcher-7.rc
	    echo "Icon=/usr/share/icons/graphite/48x48/gtk/gtk-home.png" >> $XFCEPANEL/launcher-7.rc

	fi

    else                # there is no nest

	echo "Comment=Volatile home floating in RAM" >> $XFCEPANEL/launcher-7.rc
	echo "Icon=/usr/share/icons/graphite/48x48/apps/gnome-home.png" >>  $XFCEPANEL/launcher-7.rc
    fi



    tmpid=30

    ################################# HARDDISK

    hdisks=`cat /boot/volumes | grep "^hdisk" | awk '{print $3}' | cut -d/ -f3 | uniq`
    
    for hd in `echo $hdisks | awk '{print $0}'`; do

	tmpid=`expr $tmpid + 1`
	echo "<item name=\"launcher\" id=\"$tmpid\"/>" >> $XFCEPANEL/panels.xml
	
	rm -f $XFCEPANEL/launcher-${tmpid}.rc
	cat <<EOF > $XFCEPANEL/launcher-${tmpid}.rc
[Entry 0]
Name=Harddisk
Exec=rox /mnt/${hd}
Terminal=false
StartupNotify=false
Comment=Persistent storage
Icon=/usr/share/icons/graphite/48x48/filesystems/gnome-fs-blockdev.png
EOF
    done


    devs=`cat /boot/volumes | grep -v "^hdisk"`

    ############################# CDROM & DVD
    
    for c in `echo $devs | awk '/^cd/ { print $3 } /^dvd/ { print $3 }'`; do
	
	tmpid=`expr $tmpid + 1`
	echo "<item name=\"launcher\" id=\"${tmpid}\"/>" >> $XFCEPANEL/panels.xml
	
	rm -f $XFCEPANEL/launcher-${tmpid}.rc
	cat <<EOF > $XFCEPANEL/launcher-${tmpid}.rc
[Entry 0]
Name=Cd Rom
Exec=rox ${c}
Terminal=false
StartupNotify=false
Comment=Compact Disk / DVD
Icon=/usr/share/icons/graphite/48x48/devices/gnome-dev-cdrom.png
EOF
    done

    ############################# NETWORK
    LAN=`lspci | grep -i 'ethernet'`
    if [ $LAN ]; then
	
	tmpid=`expr $tmpid + 1`
	echo "<item name=\"launcher\" id=\"${tmpid}\"/>" >> $XFCEPANEL/panels.xml

	rm -f $XFCEPANEL/launcher-${tmpid}.rc
	cat <<EOF > $XFCEPANEL/launcher-${tmpid}.rc
[Entry 0]
Name=Network
Exec=rox /mnt/shares
Terminal=false
StartupNotify=false
Comment=Shared Volumes
Icon=/mnt/shares/.DirIcon
EOF
    fi




    ############################# USB KEY 

    usbs=`echo $devs | awk '/^usb/ { print $3 }'`
    for u in ${(f)usbs}; do
	
	tmpid=`expr $tmpid + 1`
	echo "<item name=\"launcher\" id=\"${tmpid}\"/>" >> $XFCEPANEL/panels.xml
	
	rm -f $XFCEPANEL/launcher-${tmpid}.rc
	cat <<EOF > $XFCEPANEL/launcher-${tmpid}.rc
[Entry 0]
Name=Usb key
Exec=rox ${u}
Terminal=false
StartupNotify=false
Comment=Usb removable storage
Icon=/usr/share/icons/crystalsvg/48x48/devices/usbpendrive_unmount.png
EOF
    done

    ############################# PHOTO CAMERA
    if [ -r /proc/bus/usb/devices ]; then
	tmpid=`expr $tmpid + 1`
	echo "<item name=\"launcher\" id=\"${tmpid}\"/>" >> $XFCEPANEL/panels.xml
	
	rm -f $XFCEPANEL/launcher-${tmpid}.rc
	cat <<EOF > $XFCEPANEL/launcher-${tmpid}.rc
[Entry 0]
Name=Photo camera
Exec=gtkam
Terminal=false
StartupNotify=false
Comment=Usb Photo Camera
Icon=/usr/share/icons/graphite/48x48/apps/camera.png
EOF
    fi
	

    ############################# FLOPPY
    
    for d in `echo $devs | awk '/^floppy/ { print $3 }'`; do

	tmpid=`expr $tmpid + 1`
	echo "<item name=\"launcher\" id=\"${tmpid}\"/>" >> $XFCEPANEL/panels.xml

	rm -f $XFCEPANEL/launcher-${tmpid}.rc
	cat <<EOF > $XFCEPANEL/launcher-${tmpid}.rc
[Entry 0]
Name=Floppy Disk
Exec=rox ${d}
Terminal=false
StartupNotify=false
Comment=Floppy disk storage
Icon=/usr/share/icons/graphite/48x48/devices/gnome-dev-floppy.png
EOF
    done

    ############################# VOLUME
    if [ -r /dev/mixer ]; then
	tmpid=`expr $tmpid + 1`
	echo "<item name=\"xfce4-mixer\" id=\"${tmpid}\"/>" >> $XFCEPANEL/panels.xml
	
	rm -f $XFCEPANEL/launcher-${tmpid}.rc
	cat <<EOF > $XFCEPANEL/launcher-${tmpid}.rc
[mixer-plugin]
Device=/dev/mixer
LauncherCommand=volumemixer
LauncherRunInTerminal=false
LauncherUseStartupNotification=false
MasterControl=Vol
EOF
    fi


    ###########################################
    ##### END OF PANEL

cat <<EOF >> $XFCEPANEL/panels.xml
			<item name="separator" id="101"/>
			<item name="clock" id="105"/>
                </items>
        </panel>
</panels>
EOF

}


# this function is called at the end of bootstrap.sh
# it starts up X with the current configuration
bootstrap_x() {

    source /lib/dyne/zsh/common

  # remote X client-server
  XREMOTE="`get_config x_remote`"
  if [ $XREMOTE ]; then
    su -c X -indirect -query ${XREMOTE} &
    sleep 5
    xpid=`pidof X`
    if [ $xpid ]; then
      rm -f /tmp/.booting_x
    fi
    return
  fi

  # setup window managers
  act "creating socket directories for Xorg"
  mkdir /tmp/.font-unix ; chmod a+wt /tmp/.font-unix
  mkdir /tmp/.ICE-unix  ; chmod a+wt /tmp/.ICE-unix
  mkdir /tmp/.X11-unix  ; chmod a+wt /tmp/.X11-unix


  notice "initializing window managers"
  # generate window manager menu entries
  fluxbox_gen_menu
  wmaker_gen_menu
  xfce_gen_menu

  # generate window manager volumes entries
  rox_gen_volumes
  wmaker_gen_volumes
  xfce_gen_volumes
  


  USERLOGIN="`get_config user`"

  if [ $USERLOGIN = root ]; then

    # login directly into the desktop as root
    #  su - root -c xinit &
      export HOME=/root
      xinit &
      
  elif [ $USERLOGIN = multi ]; then
      
    # popup a login prompt
      xdm
      
  elif [ $USERLOGIN ]; then

    grep $USERLOGIN /etc/passwd > /dev/null
    if [ $? = 0 ]; then
    # login directly selected user
      export HOME=/home/$USERLOGIN
      setuidgid $USERLOGIN xinit &
    fi
  
  else
     
    # login directly into the desktop as root
      # su - root -c xinit &
      export HOME=/root
      exec xinit &

  fi

  # delete booting_x to signal we have succesfully started X
  # dyne_startx is executed after login
  sleep 5
  xpid=`pidof X`
  if [ $xpid ]; then
    rm -f /tmp/.booting_x
  fi
 
}

# this function is called in .xinitrc by default
dyne_startx() {
  # source /etc/LANGUAGE
  source /boot/dynenv.modules

  # honour configuration directives
  # sent thru kernel parameters and dyne.cfg

  if [ "$START_X11VNC" = "true" ]; then
    (sleep 10; x11vnc -shared -forever -display :0)&
  fi

  # success booting x with current drivers:
  rm -f /tmp/.booting_x


  startx=`get_config startx`
  if [ $startx ]; then
    exec $startx
    return
  fi



  if ! [ $WINDOWMANAGER ]; then # no .xinitrc user setting
    WINDOWMANAGER=`get_config window_manager`
    if ! [ $WINDOWMANAGER ]; then # and no dyne.cfg
      # our default stays WindowMaker
      WINDOWMANAGER=wmaker
    fi
  fi

  # prepare ROX filer for its first start
  mkdir -p $HOME/.config/rox.sourceforge.net/ROX-Filer

  if [ $WINDOWMANAGER = fluxbox ]; then

    # start the system resource monitor
    # gkrellm -w -t /usr/share/gkrellm2/Egan &

    # the multiple desktop pager
    (sleep 10; fbpager -w &)&

    # our beloved splashscreen
    if ! [ -r $HOME/.nosplash ]; then
       dynesplash &
    fi

    # start our ROX filer with pinboard and panel
    (sleep 3; rox -p Default -r Default &)&

  fi

  if [ $WINDOWMANAGER = xfce ]; then

      if [ "`which xfce4-session`" ]; then
        WINDOWMANAGER=xfce4-session
      fi

  fi

  # turn off the screensaver
  (sleep 1; xset s off -dpms &)&

  source /etc/LANGUAGE

  if [ $KEYB ]; then
    (sleep 2; /usr/X11R6/bin/setxkbmap $KEYB &)&
  fi


  # enable local connections to running X
  (sleep 5; xhost "+`hostname`")&


  # and the window manager
  exec $WINDOWMANAGER
}


