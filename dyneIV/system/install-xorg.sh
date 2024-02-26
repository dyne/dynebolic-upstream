#!/bin/sh

# fallback wm is openbox
mkdir -p /etc/X11
echo "exec openbox-session" > /etc/X11/xinitrc
# xdm logs into mate
cat <<EOF > /etc/X11/xsessionrc
pipewire &
pipewire-pulse &
wireplumber &

dbus-launch --exit-with-session mate-session
EOF
