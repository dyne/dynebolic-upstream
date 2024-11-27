#!/bin/sh

# All the packages that compose pipewire, they don't pull systemd
PIPEPACKS="gstreamer1.0-pipewire \
libkpipewire5 \
libkpipewiredmabuf5 \
libkpipewirerecord5 \
libpipeline1 \
libpipewire-0.3-0 \
libpipewire-0.3-common \
libpipewire-0.3-dev \
libpipewire-0.3-modules \
libpipewire-0.3-modules-x11 \
pipewire \
pipewire-alsa \
pipewire-audio \
pipewire-audio-client-libraries \
pipewire-bin \
pipewire-jack \
pipewire-media-session \
pipewire-pulse \
pipewire-tests \
pipewire-v4l2 \
qml-module-org-kde-pipewire"

# temporarily add devuan backport repo, pin only this packages
echo "deb http://deb.devuan.org/merged  daedalus-backports main contrib" > /etc/apt/sources.list.d/pipewire-backport.list

for item in {$PIPEPACKS} ; do
	echo "Package: $item" >> /etc/apt/preferences.d/backports
	echo "Pin: release n=daedalus-backports" >> /etc/apt/preferences.d/backports
	echo "Pin-Priority: 900" >> /etc/apt/preferences.d/backports
done

apt-get -q update

DEBIAN_FRONTEND=noninteractive apt-get -t daedalus-backports -q -y --reinstall install \
	gstreamer1.0-pipewire libkpipewire5 libkpipewiredmabuf5 libkpipewirerecord5 \
	libpipeline1 libpipewire-0.3-0:amd64 libpipewire-0.3-common libpipewire-0.3-dev \
	libpipewire-0.3-modules:amd64 libpipewire-0.3-modules-x11 pipewire pipewire-alsa \
	pipewire-audio pipewire-audio-client-libraries pipewire-bin pipewire-jack \
	pipewire-pulse pipewire-tests pipewire-v4l2 qml-module-org-kde-pipewire

# clear the package repository and the cache 
# we'll leave the pinning file so that they aren't
# overwritten during updates
rm /etc/apt/sources.list.d/pipewire-backport.list
apt-get -q update

