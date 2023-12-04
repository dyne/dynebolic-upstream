#!/bin/sh

DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
xserver-xorg-core xserver-xorg xinit xterm xserver-xorg-video-dummy \
xserver-xephyr x11-utils \
openbox python3-xdg \
mesa-utils desktop-base devuan-baseconf xdm devuan-xdm-config-override \
deepsea-icon-theme mate-desktop-environment
