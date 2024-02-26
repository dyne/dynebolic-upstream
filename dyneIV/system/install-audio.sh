#!/bin/sh

DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
pipewire-audio pavucontrol pamix \
audacity hydrogen zynaddsubfx

# https://wiki.gentoo.org/wiki/PipeWire
# https://gitweb.gentoo.org/repo/gentoo.git/tree/media-video/pipewire/files/gentoo-pipewire-launcher.in-r3
