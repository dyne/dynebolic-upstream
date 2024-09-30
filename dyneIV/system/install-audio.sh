#!/bin/sh

echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free" > /etc/apt/sources.list.d/pipewire-backport.list

apt-get -q update

DEBIAN_FRONTEND=noninteractive apt-get -t bookworm-backports -q -y --reinstall install \
	pipewire-audio pipewire pipewire-pulse pipewire-jack pipewire-bin pipewire-alsa \
	wireplumber pipewire-libcamera pipewire-v4l pipewire-tests

DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
	pavucontrol pamix audacity hydrogen zynaddsubfx

rm /etc/apt/sources.list.d/pipewire-backport.list

apt-get -q update

# https://wiki.gentoo.org/wiki/PipeWire
# https://gitweb.gentoo.org/repo/gentoo.git/tree/media-video/pipewire/files/gentoo-pipewire-launcher.in-r3
