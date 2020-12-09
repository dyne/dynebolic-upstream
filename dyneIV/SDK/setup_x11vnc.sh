#!/bin/bash

# Add a dummy screen and output for running Xorg in headless mode
cat <<EOF > /etc/X11/xorg.conf.d/10-headless.conf
Section "Monitor"
        Identifier "dummy_monitor"
        HorizSync 28.0-80.0
        VertRefresh 48.0-75.0
        Modeline "1920x1080" 172.80 1920 2040 2248 2576 1080 1081 1084 1118
EndSection

Section "Device"
        Identifier "dummy_card"
        VideoRam 256000
        Driver "dummy"
EndSection

Section "Screen"
        Identifier "dummy_screen"
        Device "dummy_card"
        Monitor "dummy_monitor"
        SubSection "Display"
        EndSubSection
EndSection
EOF

# Install xorg video driver for dummy output
apt-get install --force-yes xserver-xorg-video-dummy

# Start WindowMaker when running startx
cat <<EOF >> /etc/X11/xinitrc
exec WindowMaker
EOF

# Now run startx in one terminal (preferably using screen)
# and "start_x11vnc.sh PASSWORD" in another one
