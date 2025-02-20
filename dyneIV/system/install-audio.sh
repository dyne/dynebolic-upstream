#!/bin/sh
# Script to install PipeWire from Devuan backports without pulling systemd.
# Usage: ./install-pipewire.sh

set -e  # Exit on error

# List of PipeWire packages to install
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

# Temporary backports repository configuration
BACKPORTS_REPO="deb http://deb.devuan.org/merged daedalus-backports main contrib"
BACKPORTS_LIST="/etc/apt/sources.list.d/pipewire-backport.list"
BACKPORTS_PREFS="/etc/apt/preferences.d/pipewire-backports"

# Add Devuan backports repository
echo "Adding Devuan backports repository..."
echo "${BACKPORTS_REPO}" > "${BACKPORTS_LIST}"

# Update package lists
echo "Updating package lists..."
apt-get -q update

rm -f  /etc/apt/preferences.d/backports
for item in ${PIPEPACKS} ; do
	echo "Package: $item" >> /etc/apt/preferences.d/backports
	echo "Pin: release n=daedalus-backports" >> /etc/apt/preferences.d/backports
	echo "Pin-Priority: 900" >> /etc/apt/preferences.d/backports
	printf "\n" >> /etc/apt/preferences.d/backports
	apt-get -y --reinstall install -t daedalus-backports $item
done

# Install PipeWire packages from backports
echo "Installing PipeWire packages..."
for item in ${PIPEPACKS}; do
    echo "Installing ${item}..."
    apt-get -q -y --reinstall install -t daedalus-backports "${item}"
done

# Clean up
echo "Cleaning up..."
mv "${BACKPORTS_LIST}" /root  # Move backports list to /root to prevent overwrites
apt-get -q update  # Refresh package lists again

echo "PipeWire installation complete!"
