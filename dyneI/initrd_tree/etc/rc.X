#!/bin/sh

# We need to source /etc/profile for stuff like $LANG to work
source /etc/LANGUAGE
export LANG
export LC_ALL

echo "[*] starting X graphical interface, please standby.."
echo
echo
echo
/sbin/agetty -n -l `login -c /usr/X11R6/bin/xinit` 38400 tty7 linux;
echo
echo
echo "[!] your graphic card seems to be not supported"
echo " .  the X graphical interface will not start automatically"
echo " .  alltough you can try by hand launching \"xinit\""
echo " .  and eventually tweaking the /etc/XF86Config file"
echo " .  good luck!"

