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

if [ -z "`grep fbdev /etc/XF86Config`" ]; then
  echo "[!] your graphic card seems to lack XFree86 native support"
  echo "[!] if you are online, please report this bug with the command"
  echo "[!] 'db-bugreport' which will send your hardware configuration"
  echo "[!] to developers, thanks for your help!"
  echo
  echo "[*] in 5 seconds we will try to start framebuffer video mode"
  echo " .  resolution is limited to 800x600 16bit color depth"
  echo
  echo
  sleep 5
  mv /etc/XF86Config "/etc/XF86Config.bad-`date '+%e-%m-%y'`"
  cp /etc/XF86Config.dist /etc/XF86Config
  /sbin/agetty -n -l `login -c /usr/X11R6/bin/xinit` 38400 tty7 linux;
fi

rm /etc/XF86Config
echo
echo
echo "[!] the X graphical interface cannot start automatically"
echo "[!] you can try to configure it by yourself using the command"
echo "[!] 'xf86cfg -textmode' and choose your video hardware devices"
echo "[!] from a list of supported cards."
echo "[!] if you are online, please also do 'db-bugreport' so that"
echo "[!] dynebolic developers will be able to examine your case!"
echo
echo "[*] good luck!"
echo
echo

