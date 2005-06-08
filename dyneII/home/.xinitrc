# X initialization file
# this file lists all programs that are executed when starting X
# here you can also choose the windowmanager that is going to startup
# if you don't know what you are doing is better to not touch.

# read language settings
source /etc/LANGUAGE

# tell the system that X is booting OK
touch /boot/Xok

# set the key repeat speed for keyboard
# and turn off the screensaver
(sleep 1; xset r rate 180 30 s off -dpms &)&

# launch the cpu monitor and other gauges 
(sleep 3; gkrellm2 -t /usr/lib/gkrellm2/themes/Egan -g -0-0 &)&

# play the jingle!
(sleep 4; mplayer /usr/share/dynebolic/dixan-splashjingle.ogg &)&

# set the keyboard mapping
if [ ! -z $KEYB ]; then
  (sleep 4; /usr/X11R6/bin/setxkbmap $KEYB &)&
fi



# here you can make your choice
wmaker
#fluxbox

