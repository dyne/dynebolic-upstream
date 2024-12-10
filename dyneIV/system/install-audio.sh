#!/bin/sh
# All the packages that compose pipewire, they don't pull systemd
PIPEPACKS="gstreamer1.0-pipewire \
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
apt-get -q update

for item in ${PIPEPACKS} ; do
	echo "Package: $item" >> /etc/apt/preferences.d/backports
	echo "Pin: release n=daedalus-backports" >> /etc/apt/preferences.d/backports
	echo "Pin-Priority: 900" >> /etc/apt/preferences.d/backports
	printf "\n" >> /etc/apt/preferences.d/backports
	apt-get -y --reinstall install -t daedalus-backports $item
done

apt-get -q -y upgrade

# clear the package repository and the cache 
# we'll leave the pinning file so that they aren't
# overwritten during updates
mv /etc/apt/sources.list.d/pipewire-backport.list /root
apt-get -q update
