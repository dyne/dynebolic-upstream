#!/bin/sh


FILE_ID="\$IdL $"

source /lib/libdyne.sh
source /etc/LANGUAGE

notice "starting X graphical interface"
if [ -e /boot/Xok ]; then rm -f /boot/Xok; fi
echo
echo
echo
/sbin/agetty -n -l `login -c /usr/X11R6/bin/xinit` 38400 tty7 linux;

echo
echo

while [ -e /boot/Xok ]; do
  /sbin/agetty -n -l `login -c /usr/X11R6/bin/xinit` 38400 tty7 linux;
done

if [ -z "`grep fbdev /etc/XF86Config`" ]; then
  error "your graphic card seems to lack XFree86 native support"
  error "if you are online, please report this bug with the command"
  error "'db-bugreport' which will send your hardware configuration"
  error "to developers, thanks for your help!"
  echo
  notice "in 5 seconds we will try to start framebuffer video mode"
  act "resolution is limited to 800x600 16bit color depth"
  echo
  echo
  sleep 5
  mv /etc/XF86Config "/etc/XF86Config.bad-`date '+%e-%m-%y'`"
  cp /etc/XF86Config.dist /etc/XF86Config
  /sbin/agetty -n -l `login -c /usr/X11R6/bin/xinit` 38400 tty7 linux;
fi

while [ -e /boot/Xok ]; do
  /sbin/agetty -n -l `login -c /usr/X11R6/bin/xinit` 38400 tty7 linux;
done

echo
echo
error "the X graphical interface cannot start automatically"
error "you can try to configure it by yourself using the command"
error "'xf86cfg -textmode' and choose your video hardware devices"
error "from a list of supported cards."
error "if you are online, please also do 'db-bugreport' so that"
error "dynebolic developers will be able to examine your case!"
echo
notice "good luck!"
echo
echo

