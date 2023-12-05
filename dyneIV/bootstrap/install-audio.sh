#!/bin/sh

DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
pipewire-audio pavucontrol pamix \
audacity hydrogen zynaddsubfx
