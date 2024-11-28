#!/bin/sh

echo 'LANG="C"\nLANGUAGE="en_US:en"\nLC_ALL="C"\n' \
	 > /etc/default/locale

FREESH=freesh-archive-keyring_1.1_all.deb
dpkg -i /usr/src/${FREESH}
rm -f /usr/src/${FREESH}
DEBIAN_FRONTEND=noninteractive apt-get update -q -y
DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
	linux-image-6.11.10-gnu linux-headers-6.11.10-gnu linux-libre-6.11

# commented by fruity, we still need kernels on the iso, do not wipe it off
#rm -f /etc/apt/sources.list.d/freesh.sources
